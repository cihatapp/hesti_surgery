#!/usr/bin/env python3
"""
Generate HTML coverage report from lcov.info file
"""
import os
import sys
from pathlib import Path

def parse_lcov_file(lcov_path):
    """Parse lcov.info file and return coverage data"""
    coverage_data = []
    current_file = None
    
    with open(lcov_path, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('SF:'):
                if current_file:
                    coverage_data.append(current_file)
                current_file = {
                    'file': line[3:],
                    'lines': [],
                    'functions': [],
                    'branches': [],
                    'line_count': 0,
                    'hit_count': 0,
                }
            elif line.startswith('DA:') and current_file:
                parts = line[3:].split(',')
                if len(parts) == 2:
                    line_num = int(parts[0])
                    hit_count = int(parts[1])
                    current_file['lines'].append((line_num, hit_count))
                    current_file['line_count'] += 1
                    if hit_count > 0:
                        current_file['hit_count'] += 1
            elif line.startswith('LF:') and current_file:
                current_file['total_lines'] = int(line[3:])
            elif line.startswith('LH:') and current_file:
                current_file['hit_lines'] = int(line[3:])
            elif line == 'end_of_record' and current_file:
                coverage_data.append(current_file)
                current_file = None
    
    if current_file:
        coverage_data.append(current_file)
    
    return coverage_data

def calculate_percentage(hit, total):
    """Calculate percentage"""
    if total == 0:
        return 100.0
    return (hit / total) * 100.0

def get_file_content(file_path):
    """Read source file content"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.readlines()
    except:
        return None

def generate_html(coverage_data, output_dir):
    """Generate HTML coverage report"""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Calculate overall statistics
    total_lines = sum(f.get('total_lines', 0) for f in coverage_data)
    hit_lines = sum(f.get('hit_lines', 0) for f in coverage_data)
    overall_percentage = calculate_percentage(hit_lines, total_lines)
    
    # Generate index.html
    index_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test Coverage Report</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }}
        .header {{
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .header h1 {{
            margin: 0 0 10px 0;
            color: #333;
        }}
        .stats {{
            display: flex;
            gap: 20px;
            margin-top: 15px;
        }}
        .stat {{
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            min-width: 150px;
        }}
        .stat-label {{
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }}
        .stat-value {{
            font-size: 24px;
            font-weight: bold;
            color: #333;
        }}
        .stat-percentage {{
            font-size: 32px;
            font-weight: bold;
            color: #28AF6E;
        }}
        .file-list {{
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .file-item {{
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }}
        .file-item:hover {{
            background: #f8f9fa;
        }}
        .file-name {{
            flex: 1;
            font-family: 'Monaco', 'Courier New', monospace;
            font-size: 14px;
            color: #333;
        }}
        .file-coverage {{
            display: flex;
            align-items: center;
            gap: 15px;
        }}
        .coverage-bar {{
            width: 200px;
            height: 20px;
            background: #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
        }}
        .coverage-fill {{
            height: 100%;
            background: #28AF6E;
            transition: width 0.3s;
        }}
        .coverage-fill.low {{
            background: #ff9800;
        }}
        .coverage-fill.very-low {{
            background: #f44336;
        }}
        .coverage-text {{
            font-weight: bold;
            min-width: 60px;
            text-align: right;
        }}
        .file-details {{
            margin-top: 20px;
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .source-code {{
            font-family: 'Monaco', 'Courier New', monospace;
            font-size: 12px;
            line-height: 1.6;
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            overflow-x: auto;
        }}
        .line {{
            padding: 2px 10px;
            display: flex;
        }}
        .line-number {{
            color: #999;
            margin-right: 15px;
            min-width: 50px;
            text-align: right;
        }}
        .line-content {{
            flex: 1;
        }}
        .line.covered {{
            background: #e8f5e9;
        }}
        .line.uncovered {{
            background: #ffebee;
        }}
        a {{
            color: #28AF6E;
            text-decoration: none;
        }}
        a:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Test Coverage Report</h1>
        <div class="stats">
            <div class="stat">
                <div class="stat-label">Overall Coverage</div>
                <div class="stat-percentage">{overall_percentage:.1f}%</div>
            </div>
            <div class="stat">
                <div class="stat-label">Lines Covered</div>
                <div class="stat-value">{hit_lines:,} / {total_lines:,}</div>
            </div>
            <div class="stat">
                <div class="stat-label">Files</div>
                <div class="stat-value">{len(coverage_data)}</div>
            </div>
        </div>
    </div>
    
    <div class="file-list">
        <div class="file-item" style="background: #f8f9fa; font-weight: bold;">
            <div class="file-name">File</div>
            <div class="file-coverage">
                <div class="coverage-bar"></div>
                <div class="coverage-text">Coverage</div>
            </div>
        </div>
"""
    
    # Sort files by coverage percentage (lowest first)
    coverage_data_sorted = sorted(
        coverage_data,
        key=lambda x: calculate_percentage(x.get('hit_lines', 0), x.get('total_lines', 1))
    )
    
    for file_data in coverage_data_sorted:
        file_path = file_data['file']
        total = file_data.get('total_lines', 0)
        hit = file_data.get('hit_lines', 0)
        percentage = calculate_percentage(hit, total)
        
        # Determine coverage class
        coverage_class = ''
        if percentage < 50:
            coverage_class = 'very-low'
        elif percentage < 80:
            coverage_class = 'low'
        
        # Create file detail page
        file_slug = file_path.replace('/', '_').replace('\\', '_').replace('.', '_')
        detail_file = output_dir / f"{file_slug}.html"
        
        # Generate file detail HTML
        file_html = generate_file_detail_html(file_data, file_path, coverage_data)
        with open(detail_file, 'w', encoding='utf-8') as f:
            f.write(file_html)
        
        index_html += f"""
        <div class="file-item">
            <div class="file-name">
                <a href="{file_slug}.html">{file_path}</a>
            </div>
            <div class="file-coverage">
                <div class="coverage-bar">
                    <div class="coverage-fill {coverage_class}" style="width: {percentage:.1f}%"></div>
                </div>
                <div class="coverage-text">{percentage:.1f}%</div>
            </div>
        </div>
"""
    
    index_html += """
    </div>
</body>
</html>
"""
    
    with open(output_dir / 'index.html', 'w', encoding='utf-8') as f:
        f.write(index_html)
    
    print(f"Coverage report generated: {output_dir / 'index.html'}")
    print(f"Overall coverage: {overall_percentage:.1f}%")
    print(f"Files: {len(coverage_data)}")
    print(f"Lines covered: {hit_lines:,} / {total_lines:,}")

def generate_file_detail_html(file_data, file_path, all_files):
    """Generate HTML for individual file detail page"""
    total = file_data.get('total_lines', 0)
    hit = file_data.get('hit_lines', 0)
    percentage = calculate_percentage(hit, total)
    
    # Get source file content
    source_lines = get_file_content(file_path)
    
    # Create line coverage map
    line_coverage = {line_num: hit_count for line_num, hit_count in file_data.get('lines', [])}
    
    html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{file_path} - Coverage</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }}
        .header {{
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        .header h1 {{
            margin: 0 0 10px 0;
            color: #333;
            font-size: 18px;
            font-family: 'Monaco', 'Courier New', monospace;
        }}
        .coverage-info {{
            display: flex;
            gap: 20px;
            margin-top: 15px;
        }}
        .info-item {{
            background: #f8f9fa;
            padding: 10px 15px;
            border-radius: 6px;
        }}
        .info-label {{
            font-size: 12px;
            color: #666;
            margin-bottom: 5px;
        }}
        .info-value {{
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }}
        .source-code {{
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow-x: auto;
        }}
        .line {{
            padding: 2px 10px;
            display: flex;
            font-family: 'Monaco', 'Courier New', monospace;
            font-size: 12px;
            line-height: 1.6;
        }}
        .line-number {{
            color: #999;
            margin-right: 15px;
            min-width: 50px;
            text-align: right;
            user-select: none;
        }}
        .line-content {{
            flex: 1;
            white-space: pre;
        }}
        .line.covered {{
            background: #e8f5e9;
        }}
        .line.uncovered {{
            background: #ffebee;
        }}
        .line.no-data {{
            background: #f8f9fa;
        }}
        a {{
            color: #28AF6E;
            text-decoration: none;
        }}
        a:hover {{
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1><a href="index.html">← Back to Coverage Report</a></h1>
        <div class="coverage-info">
            <div class="info-item">
                <div class="info-label">Coverage</div>
                <div class="info-value">{percentage:.1f}%</div>
            </div>
            <div class="info-item">
                <div class="info-label">Lines Covered</div>
                <div class="info-value">{hit} / {total}</div>
            </div>
        </div>
    </div>
    
    <div class="source-code">
"""
    
    if source_lines:
        for i, line_content in enumerate(source_lines, 1):
            hit_count = line_coverage.get(i, None)
            if hit_count is None:
                line_class = 'no-data'
            elif hit_count > 0:
                line_class = 'covered'
            else:
                line_class = 'uncovered'
            
            # Escape HTML
            escaped_content = line_content.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            
            html += f"""
        <div class="line {line_class}">
            <span class="line-number">{i}</span>
            <span class="line-content">{escaped_content}</span>
        </div>
"""
    else:
        html += f"""
        <div class="line">
            <span class="line-content">Source file not found: {file_path}</span>
        </div>
"""
    
    html += """
    </div>
</body>
</html>
"""
    
    return html

def main():
    """Main function"""
    project_root = Path(__file__).parent.parent
    lcov_path = project_root / 'coverage' / 'lcov.info'
    output_dir = project_root / 'coverage' / 'html'
    
    if not lcov_path.exists():
        print(f"Error: {lcov_path} not found")
        print("Please run: flutter test --coverage")
        sys.exit(1)
    
    print(f"Parsing {lcov_path}...")
    coverage_data = parse_lcov_file(lcov_path)
    
    print(f"Generating HTML report in {output_dir}...")
    generate_html(coverage_data, output_dir)
    
    print(f"\n✅ Report generated successfully!")
    print(f"Open: {output_dir / 'index.html'}")

if __name__ == '__main__':
    main()
