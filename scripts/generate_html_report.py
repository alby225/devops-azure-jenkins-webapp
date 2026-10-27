import os
import re

def markdown_to_html(md_text):
    # Convert headings
    html = md_text
    
    # Tables
    lines = html.split('\n')
    in_table = False
    table_lines = []
    output_lines = []
    
    for line in lines:
        if '|' in line and not line.strip().startswith('```'):
            in_table = True
            table_lines.append(line)
        else:
            if in_table:
                # render table
                table_html = "<div class='table-container'><table>"
                header_done = False
                for tline in table_lines:
                    cols = [c.strip() for c in tline.split('|')[1:-1]]
                    if not cols or all(set(c) <= set('-: ') for c in cols):
                        header_done = True
                        continue
                    if not header_done:
                        table_html += "<tr>" + "".join(f"<th>{c}</th>" for c in cols) + "</tr>"
                    else:
                        table_html += "<tr>" + "".join(f"<td>{c}</td>" for c in cols) + "</tr>"
                table_html += "</table></div>"
                output_lines.append(table_html)
                in_table = False
                table_lines = []
            output_lines.append(line)
            
    if in_table:
        table_html = "<div class='table-container'><table>"
        header_done = False
        for tline in table_lines:
            cols = [c.strip() for c in tline.split('|')[1:-1]]
            if not cols or all(set(c) <= set('-: ') for c in cols):
                header_done = True
                continue
            if not header_done:
                table_html += "<tr>" + "".join(f"<th>{c}</th>" for c in cols) + "</tr>"
            else:
                table_html += "<tr>" + "".join(f"<td>{c}</td>" for c in cols) + "</tr>"
        table_html += "</table></div>"
        output_lines.append(table_html)

    html = '\n'.join(output_lines)

    # Code blocks
    html = re.sub(r'```([a-zA-Z0-9_-]*)\n(.*?)```', r'<pre class="code-block"><code>\2</code></pre>', html, flags=re.DOTALL)
    
    # Inline code
    html = re.sub(r'`([^`]+)`', r'<code>\1</code>', html)

    # Headers
    html = re.sub(r'^### (.*?)$', r'<h3>\1</h3>', html, flags=re.M)
    html = re.sub(r'^## (.*?)$', r'<h2>\1</h2>', html, flags=re.M)
    html = re.sub(r'^# (.*?)$', r'<h1>\1</h1>', html, flags=re.M)

    # Bold and italics
    html = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', html)
    html = re.sub(r'\*(.*?)\*', r'<em>\1</em>', html)

    # Blockquotes / Callouts
    html = re.sub(r'^> (.*?)$', r'<div class="callout"><p>\1</p></div>', html, flags=re.M)

    # Horizontal rules
    html = re.sub(r'^---$', r'<hr class="divider" />', html, flags=re.M)

    # Bullet lists
    html = re.sub(r'^\s*-\s+(.*?)$', r'<li>\1</li>', html, flags=re.M)
    html = re.sub(r'(<li>.*?</li>\n?)+', r'<ul>\g<0></ul>', html)

    # Paragraphs
    paragraphs = html.split('\n\n')
    processed_p = []
    for p in paragraphs:
        p_strip = p.strip()
        if p_strip.startswith('<h') or p_strip.startswith('<pre') or p_strip.startswith('<div') or p_strip.startswith('<hr') or p_strip.startswith('<ul'):
            processed_p.append(p_strip)
        elif p_strip:
            processed_p.append(f'<p>{p_strip}</p>')
    html = '\n\n'.join(processed_p)

    # Screenshot boxes styling
    html = re.sub(r'(\[SCREENSHOT PLACEHOLDER.*?\])', r'<div class="screenshot-box"><span class="box-tag">📸 SCREENSHOT INSERTION POINT</span>\1</div>', html)

    template = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>DevOps 3rd IA Project Report</title>
  <style>
    @page {{
      size: A4;
      margin: 20mm;
    }}
    body {{
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      line-height: 1.6;
      color: #1e293b;
      background: #f8fafc;
      padding: 30px;
      margin: 0;
    }}
    .report-paper {{
      background: #ffffff;
      max-width: 900px;
      margin: 0 auto;
      padding: 45px 55px;
      border: 1px solid #e2e8f0;
      box-shadow: 0 4px 20px rgba(0,0,0,0.06);
      border-radius: 6px;
    }}
    h1 {{
      color: #0f172a;
      font-size: 24px;
      text-align: center;
      margin-bottom: 5px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }}
    h2 {{
      color: #0284c7;
      font-size: 18px;
      text-align: center;
      margin-top: 0;
      font-weight: 600;
      border-bottom: 2px solid #0284c7;
      padding-bottom: 12px;
      margin-bottom: 25px;
    }}
    h3 {{
      color: #0f172a;
      font-size: 15px;
      margin-top: 25px;
      margin-bottom: 10px;
      border-left: 4px solid #0284c7;
      padding-left: 10px;
    }}
    p {{
      margin: 10px 0;
      font-size: 13.5px;
      color: #334155;
      text-align: justify;
    }}
    ul, ol {{
      font-size: 13.5px;
      color: #334155;
      padding-left: 25px;
    }}
    li {{
      margin-bottom: 6px;
    }}
    .divider {{
      border: 0;
      height: 1px;
      background: #cbd5e1;
      margin: 25px 0;
    }}
    .table-container {{
      overflow-x: auto;
      margin: 15px 0;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      font-size: 12.5px;
      margin: 10px 0;
    }}
    th, td {{
      border: 1px solid #cbd5e1;
      padding: 8px 12px;
      text-align: left;
    }}
    th {{
      background-color: #f1f5f9;
      color: #0f172a;
      font-weight: 600;
    }}
    tr:nth-child(even) {{
      background-color: #f8fafc;
    }}
    .code-block {{
      background: #0f172a;
      color: #f8fafc;
      padding: 14px;
      border-radius: 6px;
      font-size: 12px;
      font-family: 'Consolas', 'Courier New', monospace;
      overflow-x: auto;
      white-space: pre;
      line-height: 1.45;
    }}
    code {{
      background: #e2e8f0;
      color: #0f172a;
      padding: 2px 5px;
      border-radius: 3px;
      font-size: 12px;
      font-family: 'Consolas', monospace;
    }}
    .callout {{
      background: #eff6ff;
      border-left: 4px solid #3b82f6;
      padding: 10px 15px;
      margin: 15px 0;
      border-radius: 0 4px 4px 0;
    }}
    .callout p {{
      margin: 0;
      color: #1e40af;
      font-weight: 500;
    }}
    .screenshot-box {{
      border: 2px dashed #0284c7;
      background: #f0f9ff;
      padding: 20px;
      margin: 20px 0;
      text-align: center;
      border-radius: 6px;
      color: #0369a1;
      font-weight: 600;
      font-size: 13px;
    }}
    .box-tag {{
      display: block;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 1px;
      margin-bottom: 5px;
      color: #0284c7;
    }}
    .print-bar {{
      max-width: 900px;
      margin: 0 auto 20px auto;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #0f172a;
      color: white;
      padding: 12px 20px;
      border-radius: 6px;
    }}
    .print-btn {{
      background: #0284c7;
      color: white;
      border: none;
      padding: 8px 18px;
      border-radius: 4px;
      font-weight: 600;
      cursor: pointer;
    }}
    .print-btn:hover {{
      background: #0369a1;
    }}
    @media print {{
      body {{
        background: #ffffff;
        padding: 0;
      }}
      .print-bar {{
        display: none;
      }}
      .report-paper {{
        border: none;
        box-shadow: none;
        padding: 0;
        max-width: 100%;
      }}
    }}
  </style>
</head>
<body>
  <div class="print-bar">
    <span><strong>DevOps 3rd IA Project Report Ready:</strong> Click button to print or save directly as PDF</span>
    <button class="print-btn" onclick="window.print()">Print / Save as PDF</button>
  </div>
  <div class="report-paper">
    {html}
  </div>
</body>
</html>
"""
    return template

if __name__ == '__main__':
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    md_file = os.path.join(base_dir, 'docs', 'PROJECT_REPORT.md')
    out_html = os.path.join(base_dir, 'docs', 'PROJECT_REPORT.html')
    
    with open(md_file, 'r', encoding='utf-8') as f:
        md_content = f.read()
        
    html_output = markdown_to_html(md_content)
    with open(out_html, 'w', encoding='utf-8') as f:
        f.write(html_output)
        
    print(f"Generated printable report HTML at: {out_html}")
