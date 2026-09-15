import os

def clean_file(path: str):
    with open(path, 'r', encoding='utf-8', errors='ignore') as fp:
        text = fp.read()
    
    orig = text
    # Comprehensive replacements for double UTF-8 / mojibake
    replacements = [
        ('GRAMÁTICA', 'GRAMÁTICA'),
        ('GRAMÃ\x81TICA', 'GRAMÁTICA'),
        ('ACCIÓN', 'ACCIÓN'),
        ('ACCIÃ\x93N', 'ACCIÓN'),
        ('PRÁCTICA', 'PRÁCTICA'),
        ('PRÃ\x81CTICA', 'PRÁCTICA'),
        ('PRÁCTICA', 'PRÁCTICA'),
        ('SECCIÓN', 'SECCIÓN'),
        ('SECCIÃ\x93N', 'SECCIÓN'),
        ('PRONUNCIACIÓN', 'PRONUNCIACIÓN'),
        ('PRONUNCIACIÃ\x93N', 'PRONUNCIACIÓN'),
        ('GUÍA', 'GUÍA'),
        ('GUÃ\x8dA', 'GUÍA'),
        ('FÓRMULA', 'FÓRMULA'),
        ('Fórmula', 'Fórmula'),
        ('Sintáctica', 'Sintáctica'),
        ('SINTÁCTICA', 'SINTÁCTICA'),
        ('OPCIÓN', 'OPCIÓN'),
        ('OPCIÃ\x93N', 'OPCIÓN'),
        ('ANÁLISIS', 'ANÁLISIS'),
        ('CRÍTICO', 'CRÍTICO'),
        ('MÉTRICA', 'MÉTRICA'),
        ('Métrica', 'Métrica'),
        ('Métricas', 'Métricas'),
        ('•', '•'),
        ('“', '“'),
        ('â€\x9d', '”'),
        ('â€\x9c', '“'),
        ('’', '’'),
        ('‘', '‘'),
        ('—', '—'),
        ('—', '—'),
        ('á', 'á'),
        ('é', 'é'),
        ('í', 'í'),
        ('ó', 'ó'),
        ('ú', 'ú'),
        ('ñ', 'ñ'),
        ('Ã\x81', 'Á'),
        ('Ã\x89', 'É'),
        ('Ã\x8d', 'Í'),
        ('Ã\x93', 'Ó'),
        ('Ã\x9a', 'Ú'),
        ('Ã\x91', 'Ñ'),
        ('·', '·'),
        ('', ''),
        ('/riː ˈfæk.tərd/', '/riː ˈfæk.tərd/'),
    ]

    for k, v in replacements:
        text = text.replace(k, v)

    if text != orig:
        with open(path, 'w', encoding='utf-8') as fp:
            fp.write(text)
        return True
    return False

root_dir = r'c:\Users\IvN\Desktop\Ingles'
cleaned = []
for root, dirs, files in os.walk(root_dir):
    if any(i in root for i in ['.dart_tool', '.git', 'build', '.idea']):
        continue
    for f in files:
        if f.endswith(('.dart', '.json', '.arb', '.md', '.py', '.txt')):
            p = os.path.join(root, f)
            if clean_file(p):
                cleaned.append(p)

print(f"Cleaned {len(cleaned)} files:")
for c in cleaned:
    print(f" - {c}")
