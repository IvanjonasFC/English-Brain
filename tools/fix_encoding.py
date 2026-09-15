import os

def fix_text(s: str) -> str:
    try:
        return s.encode('cp1252').decode('utf-8')
    except Exception:
        pass
    
    # Try line by line with cp1252
    lines = []
    for line in s.split('\n'):
        try:
            lines.append(line.encode('cp1252').decode('utf-8'))
        except Exception:
            # character by character replacement fallback
            fixed_line = line
            rep = {
                'OPCIÓN': 'OPCIÓN',
                'OPCIÃ\x93N': 'OPCIÓN',
                'OPCIÃ N': 'OPCIÓN',
                'inglés': 'inglés',
                'técnico': 'técnico',
                'técnica': 'técnica',
                'técnicos': 'técnicos',
                'términos': 'términos',
                'redacción': 'redacción',
                'Fórmula': 'Fórmula',
                'Sintáctica': 'Sintáctica',
                '“': '“',
                'â€\x9d': '”',
                'â€\x9c': '“',
                'â€': '”',
                '’': '’',
                '•': '•',
                'á': 'á',
                'é': 'é',
                'í': 'í',
                'ó': 'ó',
                'ú': 'ú',
                'ñ': 'ñ',
                'Ã\x93': 'Ó',
                '·': '·',
                '': '',
            }
            for k, v in rep.items():
                fixed_line = fixed_line.replace(k, v)
            lines.append(fixed_line)
    return '\n'.join(lines)

app_dir = r'c:\Users\IvN\Desktop\Ingles\app'
fixed_files = []
for root, dirs, files in os.walk(app_dir):
    if any(ignore in root for ignore in ['.dart_tool', '.git', 'build']):
        continue
    for f in files:
        if f.endswith('.dart'):
            p = os.path.join(root, f)
            with open(p, 'r', encoding='utf-8', errors='ignore') as fp:
                content = fp.read()
            if any(marker in content for marker in ['Ã', '', 'â€', '’', '“']):
                new_content = fix_text(content)
                if new_content != content:
                    with open(p, 'w', encoding='utf-8') as fp:
                        fp.write(new_content)
                    fixed_files.append(p)

print(f"Fixed {len(fixed_files)} files:")
for f in fixed_files:
    print(f" - {f}")
