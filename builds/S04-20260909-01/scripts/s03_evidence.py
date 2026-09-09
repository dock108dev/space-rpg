"""Bind evidence to runtime bytes, including import settings and UID sidecars."""
import hashlib,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def record_runtime(out,game_copy):
    files=[(p,'game/'+str(p.relative_to(game_copy))) for p in game_copy.rglob('*') if p.is_file() and '.godot' not in p.parts]
    files += [(p,str(p.relative_to(ROOT))) for p in (ROOT/'scripts').glob('*') if p.is_file()]
    files += [(p,p.name) for p in ROOT.glob('Launch*.command')]
    files.sort(key=lambda item:item[1])
    manifest=''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+name+'\n' for p,name in files)
    (out/'runtime.sha256').write_text(manifest)
    with tarfile.open(out/'runtime-source.tar.gz','w:gz') as archive:
        for p,name in files:archive.add(p,arcname=name)
    return hashlib.sha256(manifest.encode()).hexdigest()
