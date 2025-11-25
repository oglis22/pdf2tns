#!/usr/bin/env python3
"""
PDF to TI-Nspire TNS Converter
Converts PDFs to beautifully formatted scrollable TNS files
"""
import subprocess
import sys
import os
import re

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF using pdftotext"""
    try:
        result = subprocess.run(
            ['pdftotext', '-layout', pdf_path, '-'],
            capture_output=True,
            text=True,
            timeout=30
        )
        return result.stdout
    except Exception as e:
        print(f"  ✗ Error extracting text: {e}")
        return None

def detect_line_type(line):
    """Detect formatting type"""
    stripped = line.strip()

    if not stripped:
        return 'empty', ''

    # Headlines (all caps or ends with :)
    if len(stripped) < 50 and (stripped.isupper() or stripped.endswith(':')):
        return 'headline', stripped

    # Numbered lists
    if re.match(r'^[\da-z]+[\)\.]\s+', stripped):
        return 'numbered', stripped

    # Bullet points
    if re.match(r'^[•\-\*\+]\s+', stripped):
        return 'bullet', re.sub(r'^[•\-\*\+]\s+', '• ', stripped)

    # Indented text
    indent = len(line) - len(line.lstrip())
    if indent > 2:
        return 'indented', '  ' + stripped

    return 'text', stripped

def wrap_text(text, max_length):
    """Wrap text at word boundaries"""
    if len(text) <= max_length:
        return [text]

    lines = []
    while len(text) > max_length:
        break_point = text.rfind(' ', 0, max_length)
        if break_point == -1:
            break_point = max_length

        lines.append(text[:break_point].strip())
        text = text[break_point:].strip()

    if text:
        lines.append(text)

    return lines

def format_text_smart(text, max_line_length=48):
    """Format text with smart structure detection"""
    if not text:
        return []

    raw_lines = text.split('\n')
    formatted = []
    buffer = ""
    prev_type = None

    for line in raw_lines:
        line_type, content = detect_line_type(line)

        if line_type == 'empty':
            if formatted and formatted[-1] != '':
                formatted.append('')
            continue

        if line_type == 'headline':
            if buffer:
                formatted.extend(wrap_text(buffer, max_line_length))
                buffer = ""

            if formatted and formatted[-1] != '':
                formatted.append('')
            formatted.append('=== ' + content.upper() + ' ===')
            formatted.append('')

        elif line_type in ['bullet', 'numbered', 'indented']:
            if buffer:
                formatted.extend(wrap_text(buffer, max_line_length))
                buffer = ""

            wrapped = wrap_text(content, max_line_length - 2)
            for i, wl in enumerate(wrapped):
                if i == 0:
                    formatted.append(wl)
                else:
                    formatted.append('  ' + wl[2:] if len(wl) > 2 else wl)

        else:
            if buffer and not buffer.endswith(' '):
                buffer += ' '
            buffer += content

        prev_type = line_type

    if buffer:
        formatted.extend(wrap_text(buffer, max_line_length))

    return formatted

def create_scrollable_lua(title, content_lines, output_file):
    """Create formatted scrollable Lua script"""

    escaped_lines = []
    for line in content_lines:
        line = line.replace('\\', '\\\\').replace('"', '\\"')
        if len(line) > 200:
            line = line[:197] + "..."
        escaped_lines.append(f'"{line}"')

    if len(escaped_lines) > 600:
        escaped_lines = escaped_lines[:600]
        escaped_lines.append('"[Text gekürzt]"')

    lua_code = f'''-- {title}

local lines = {{
{",".join(f"{chr(10)}{line}" for line in escaped_lines)}
}}

local scrollY = 0
local lineHeight = 13

function on.paint(gc)
    local w = platform.window:width()
    local h = platform.window:height()

    gc:setColorRGB(250, 250, 250)
    gc:fillRect(0, 0, w, h)

    -- Title bar
    gc:setColorRGB(0, 50, 120)
    gc:fillRect(0, 0, w, 28)
    gc:setColorRGB(255, 255, 255)
    gc:setFont("sansserif", "b", 11)
    gc:drawString("{title}", 5, 6, "top")

    -- Content
    local y = 33 - scrollY
    for i, line in ipairs(lines) do
        if y > 25 and y < h + 20 then
            local isHeadline = line:match("^===")
            local isBullet = line:match("^•")

            if isHeadline then
                gc:setColorRGB(0, 80, 160)
                gc:setFont("sansserif", "b", 11)
                local cleanLine = line:gsub("===", ""):gsub("^%s+", ""):gsub("%s+$", "")
                gc:drawString(cleanLine, 5, y, "top")
            elseif isBullet then
                gc:setColorRGB(40, 40, 40)
                gc:setFont("sansserif", "r", 10)
                gc:drawString(line, 8, y, "top")
            else
                gc:setColorRGB(0, 0, 0)
                gc:setFont("sansserif", "r", 10)
                gc:drawString(line, 5, y, "top")
            end
        end
        y = y + lineHeight
    end

    -- Scrollbar
    local contentHeight = #lines * lineHeight
    if contentHeight > h - 33 then
        gc:setColorRGB(230, 230, 230)
        gc:fillRect(w - 10, 30, 8, h - 30)

        gc:setColorRGB(100, 100, 100)
        local barHeight = math.max(25, (h - 33) * (h - 33) / contentHeight)
        local maxScroll = contentHeight - (h - 33)
        local scrollPercent = math.min(1, scrollY / maxScroll)
        local barY = 30 + (h - 33 - barHeight) * scrollPercent
        gc:fillRect(w - 9, barY, 6, barHeight)
    end

    gc:setColorRGB(200, 200, 200)
    gc:setFont("sansserif", "r", 8)
    gc:drawString("Scroll: ↑↓ Pfeiltasten", 5, h - 12, "top")
end

function on.arrowKey(key)
    local h = platform.window:height()
    local maxScroll = math.max(0, (#lines * lineHeight) - (h - 33))

    if key == "up" then
        scrollY = math.max(0, scrollY - 35)
        platform.window:invalidate()
    elseif key == "down" then
        scrollY = math.min(maxScroll, scrollY + 35)
        platform.window:invalidate()
    end
end

function on.resize()
    platform.window:invalidate()
end
'''

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(lua_code)

    return output_file

def convert_pdf_to_tns(pdf_path, output_dir, luna_path):
    """Convert single PDF to TNS"""
    basename = os.path.splitext(os.path.basename(pdf_path))[0]

    print(f"[{basename}]")
    print("  → Extracting text...")

    text = extract_text_from_pdf(pdf_path)
    if not text:
        print("  ✗ Failed")
        return False

    print(f"  → Extracted {len(text)} chars")

    lines = format_text_smart(text)
    print(f"  → Formatted {len(lines)} lines")

    lua_file = os.path.join(output_dir, f"{basename}.lua")
    tns_file = os.path.join(output_dir, f"{basename}.tns")

    create_scrollable_lua(basename, lines, lua_file)

    print("  → Creating TNS...")
    try:
        subprocess.run(
            [luna_path, lua_file, tns_file],
            cwd=os.path.dirname(luna_path),
            capture_output=True,
            timeout=30
        )

        if os.path.exists(tns_file):
            size = os.path.getsize(tns_file)
            print(f"  ✓ Created: {basename}.tns ({size} bytes)")
            return True
        else:
            print("  ✗ TNS creation failed")
            return False
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 4:
        print("Usage: pdf_converter.py <pdf_path> <output_dir> <luna_path>")
        sys.exit(1)

    convert_pdf_to_tns(sys.argv[1], sys.argv[2], sys.argv[3])
