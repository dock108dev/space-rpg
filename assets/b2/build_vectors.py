"""Editable B2 illustration source. Original vector drawings; no downloaded art.
Regenerate runtime SVG cutouts with python3 assets/b2/build_vectors.py.
"""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT/'game/art/b2'
DEFS = '''<defs><linearGradient id="wall" x2="0" y2="1"><stop stop-color="#526375"/><stop offset="1" stop-color="#2a3946"/></linearGradient><linearGradient id="floor" x2="0" y2="1"><stop stop-color="#65706f"/><stop offset="1" stop-color="#3b454a"/></linearGradient><linearGradient id="wood" x2="0" y2="1"><stop stop-color="#9d8970"/><stop offset="1" stop-color="#5e554a"/></linearGradient><linearGradient id="cloth" x2="1" y2="1"><stop stop-color="#c29d68"/><stop offset="1" stop-color="#806344"/></linearGradient><linearGradient id="metal" x2="1" y2="1"><stop stop-color="#9caeb3"/><stop offset=".45" stop-color="#657f86"/><stop offset="1" stop-color="#33494f"/></linearGradient><linearGradient id="coat" x2="1" y2="1"><stop stop-color="#c5a36f"/><stop offset=".5" stop-color="#98724b"/><stop offset="1" stop-color="#634f3b"/></linearGradient><linearGradient id="suit" x2="1" y2="0"><stop stop-color="#30434e"/><stop offset=".5" stop-color="#5a727a"/><stop offset="1" stop-color="#24323e"/></linearGradient></defs>'''
# Crosshatching and irregular specks are part of the original drawing source,
# kept deterministic and attached to each filled silhouette (no loose pixels).
DEFS=DEFS.replace('</defs>', '<pattern id="inkgrain" width="19" height="23" patternUnits="userSpaceOnUse"><path d="M2 4l3-1 M12 8l4-1 M4 17l2 2 M15 21l2-3" stroke="#162c33" stroke-opacity=".16" stroke-width=".7"/><path d="M8 1l3 1 M1 11l2 1 M10 16l4-1" stroke="#f5edcb" stroke-opacity=".14" stroke-width=".65"/></pattern></defs>')
def svg(path,w,h,body):
    def hatch(match):
        element=match.group(0)
        if 'fill="none"' in element or 'opacity=' in element or not re.search(r'fill="(?:url|#)',element): return element
        overlay=re.sub(r'fill="[^"]*"','fill="url(#inkgrain)"',element,count=1)
        overlay=re.sub(r' stroke(?:-width)?="[^"]*"','',overlay)
        return element+overlay
    body=re.sub(r'<(?:path|rect)\b[^>]+/>',hatch,body)
    path=OUT/path;path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">{DEFS}{body}</svg>\n')

def line(x1,y1,x2,y2,c='#a5bab7',o='.16',width=1):
    return f'<path d="M{x1},{y1} L{x2},{y2}" fill="none" stroke="{c}" stroke-opacity="{o}" stroke-width="{width}"/>'

# Distinct sheltered interior: blue-grey structural walls, broad warm floorboards,
# shared-service counter, floor runner and clearly public refuge signage.
b='<rect x="170" y="170" width="902" height="514" rx="9" fill="#15252f"/>'
b+='<path d="M204 206 L1008 206 L1048 668 L164 668 Z" fill="#101d24" opacity=".55"/>'
b+='<rect x="208" y="194" width="800" height="478" fill="url(#floor)" stroke="#1e2d35" stroke-width="5"/>'
b+='<path d="M208 194H1008V237H208Z" fill="url(#wall)" stroke="#192a33" stroke-width="4"/>'
for x in [208,340,474,608,742,876,1008]:
    b+=f'<path d="M{x} 194V235" stroke="#859b9e" stroke-opacity=".32" stroke-width="3"/>'
b+='<path d="M214 222H1002" stroke="#c1c9b9" stroke-opacity=".45" stroke-width="3"/>'
for y in range(238,673,32):
    b+=line(208,y,1008,y,'#b4b1a2','.20',2)
    for x in range(208+(64 if (y//32)%2 else 0),1008,128): b+=line(x,y,x,y+32,'#1d3036','.25',2)
# Runner identifies shared circulation without changing nav geometry.
b+='<path d="M467 256H615V637H467Z" fill="#73858a" stroke="#243b46" stroke-width="4"/>'
b+='<path d="M478 259H604V635H478Z" fill="none" stroke="#d0c4a6" stroke-width="2" stroke-dasharray="4 9"/>'
b+='<path d="M488 265V630 M596 265V630" stroke="#425d67" stroke-width="4"/>'
b+='<rect x="667" y="256" width="234" height="205" rx="9" fill="#354c57" stroke="#789192" stroke-width="3"/>'
b+='<path d="M680 271H888V447H680Z" fill="none" stroke="#c0b28f" stroke-opacity=".6" stroke-width="2"/>'
# Wall lamps, pipes and public shelter notice.
for x in [260,942]:
    b+=f'<path d="M{x} 192V209" stroke="#202d33" stroke-width="7"/><path d="M{x-15} 208H{x+15}L{x+22} 220H{x-22}Z" fill="#adac94" stroke="#263941" stroke-width="3"/><path d="M{x-22} 223L{x-47} 267H{x+47}L{x+22} 223Z" fill="#e2d4a0" opacity=".07"/>'
b+='<rect x="388" y="184" width="427" height="47" rx="4" fill="#253c49" stroke="#a7bab6" stroke-width="2"/><text x="601" y="203" text-anchor="middle" font-family="sans-serif" font-size="15" fill="#e9e3d2">TEMPORARY SHELTER</text><text x="601" y="221" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#bdcbd0">SHARED REFUGE · NOT OWNED · NOT PRIVATE</text>'
# Mechanical wall detail; no usable character feed.
b+='<path d="M1008 245h26v333h-22" fill="none" stroke="#243743" stroke-width="12"/><path d="M1008 245h26v333h-22" fill="none" stroke="#759091" stroke-width="4"/>'
b+='<path d="M216 638H1000" stroke="#bcb797" stroke-opacity=".22" stroke-width="2"/>'
svg(Path('shelter_room.svg'),1280,720,b)

b='<rect x="173" y="172" width="892" height="510" rx="8" fill="#1b272d"/>'
b+='<path d="M208 184H1008V240H208Z" fill="url(#wall)" stroke="#18252c" stroke-width="4"/>'
for x,name in [(245,'MARKET'),(486,'COLLECTION'),(770,'ARCADE')]:
    b+=f'<rect x="{x}" y="184" width="176" height="44" rx="3" fill="#263b40" stroke="#718184" stroke-width="2"/><path d="M{x+9} 228V239H{x+168}V228" fill="#887b68"/><text x="{x+88}" y="211" text-anchor="middle" font-family="sans-serif" font-size="15" fill="#d5ceac">{name}</text>'
# Art only framing leaves historic floor texture unobscured.
b+='<path d="M216 245V660H1000V245" fill="none" stroke="#768883" stroke-width="4"/><path d="M228 256V647H988V256" fill="none" stroke="#bead76" stroke-width="2" stroke-dasharray="9 8"/>'
b+='<path d="M1019 251v137 M1019 416v240" stroke="#8c6d4c" stroke-width="5"/>'
svg(Path('concourse_frame.svg'),1280,720,b)

# Shelter cot and its associated one-cell hamper: physical obstacles.
svg(Path('cot.svg'),150,128,'''<ellipse cx="73" cy="118" rx="71" ry="9" fill="#101e25" opacity=".5"/><path d="M14 49L130 34L142 98L25 117Z" fill="#334b56" stroke="#1c2a33" stroke-width="4"/><path d="M23 110v13 M129 92v24" stroke="#202e35" stroke-width="7"/><path d="M8 40L123 23L140 81L23 102Z" fill="#83969a" stroke="#25353d" stroke-width="4"/><path d="M12 39L123 24L134 65L23 84Z" fill="#b7b7a3" stroke="#3b4f51" stroke-width="3"/><path d="M41 36L123 24L135 65L51 80Z" fill="#7a8f91"/><path d="M55 36L60 73 M75 32L80 70 M98 29L103 65" stroke="#aec1b9" stroke-opacity=".45" stroke-width="2"/><path d="M14 40l20-4 9 21-22 5Z" fill="#d2cbb2" stroke="#596867" stroke-width="2"/><path d="M23 85L137 66L140 84L24 104Z" fill="#536d76"/><path d="M14 20V59 M122 5V42" stroke="#293d48" stroke-width="6"/><path d="M14 23L121 7" stroke="#8c9fa0" stroke-width="6"/><path d="M25 100L140 81" stroke="#c4c1a3" stroke-width="2"/>''')
svg(Path('hamper.svg'),66,74,'''<ellipse cx="34" cy="67" rx="31" ry="7" fill="#12262c" opacity=".5"/><path d="M6 25L55 16L63 58L15 70Z" fill="#766b54" stroke="#25363a" stroke-width="3"/><path d="M6 25L15 70L21 33L12 17Z" fill="#524d3f"/><path d="M9 24L53 17L59 27L15 36Z" fill="#a59472" stroke="#354347" stroke-width="2"/><path d="M18 14q7-14 15-6l6 6 11-8 5 19-30 6Z" fill="#97aaa3" stroke="#4b6366" stroke-width="2"/><path d="M22 42L58 34 M23 49L59 42 M25 57L60 50" stroke="#b6a27a" stroke-width="2"/>''')
svg(Path('supply_locker.svg'),85,143,'''<ellipse cx="43" cy="134" rx="40" ry="8" fill="#10212a" opacity=".6"/><path d="M7 25L60 10L78 27V128L25 140L7 124Z" fill="#344c59" stroke="#182d37" stroke-width="4"/><path d="M7 25L61 11L79 27L25 42Z" fill="#a0aea5" stroke="#243b48" stroke-width="3"/><path d="M25 42L78 27V126L25 139Z" fill="url(#metal)" stroke="#243a44" stroke-width="3"/><path d="M32 48L70 39V79L32 88Z M32 94L70 84V120L32 129Z" fill="#607e85" stroke="#293f4b" stroke-width="2"/><path d="M39 54l23-6 M39 61l23-6 M39 68l23-6" stroke="#bcc6b7" stroke-width="2"/><path d="M64 93v14 M66 58v12" stroke="#d4c391" stroke-width="4"/><path d="M12 43v72" stroke="#738c91" stroke-opacity=".5" stroke-width="3"/><path d="M16 24l23-6 5 7-22 7Z" fill="#c6b284"/><path d="M48 0h12v13H48Z" fill="#8b7758" stroke="#283e42" stroke-width="2"/>''')
svg(Path('bench.svg'),78,76,'''<ellipse cx="38" cy="68" rx="36" ry="7" fill="#0c2028" opacity=".45"/><path d="M11 39v29 M64 28v31 M68 46v23 M19 53v20" stroke="#243943" stroke-width="6"/><path d="M6 30L57 18L73 39L19 54Z" fill="url(#wood)" stroke="#213740" stroke-width="3"/><path d="M14 37l51-13 M18 45l51-13" stroke="#c0ae83" stroke-width="2"/><path d="M8 7L59 0L60 17L10 26Z" fill="#72888d" stroke="#263d48" stroke-width="3"/><path d="M12 22v17 M58 16v14" stroke="#364e59" stroke-width="5"/>''')
svg(Path('orientation_desk.svg'),117,113,'''<ellipse cx="59" cy="103" rx="55" ry="9" fill="#10232b" opacity=".48"/><path d="M12 47L91 29L106 44V94L28 113L12 95Z" fill="#3c565f" stroke="#203741" stroke-width="4"/><path d="M28 66L105 46V92L28 110Z" fill="url(#metal)" stroke="#294049" stroke-width="3"/><path d="M4 45L89 25L115 43L27 67Z" fill="#a4ac9a" stroke="#243f49" stroke-width="4"/><path d="M45 71L86 61V84L45 94Z" fill="#40596b" stroke="#a8b9ad" stroke-width="2"/><path d="M61 69v17 M53 79l17-5" stroke="#d9d5b3" stroke-width="3"/><path d="M30 35L57 30L68 37L40 44Z" fill="#e2d4ad" stroke="#635f4d" stroke-width="2"/><path d="M76 9l19-4 5 29-21 5Z" fill="#95adb1" stroke="#2a414d" stroke-width="3"/><path d="M82 15l10-2 M84 21l8-2" stroke="#e5ddbd" stroke-width="2"/>''')
svg(Path('doorway.svg'),125,150,'''<ellipse cx="61" cy="141" rx="60" ry="8" fill="#10212a" opacity=".48"/><path d="M7 143V26L19 10H104L119 27V143H102V40H25V143Z" fill="#516c76" stroke="#20343e" stroke-width="4"/><path d="M7 28L22 12H104L117 27H30L25 40H8Z" fill="#a7b5ac"/><path d="M28 43v95 M100 42v96" stroke="#c1caaa" stroke-width="3"/><path d="M10 134h14 M103 134h14" stroke="#b6c4b3" stroke-width="5"/><rect x="37" y="18" width="52" height="17" rx="2" fill="#243e4e"/><path d="M48 26h31 M73 22l7 4-7 4" fill="none" stroke="#bbd2ca" stroke-width="2"/><path d="M8 60h14v18H8 M103 61h14v17h-14" fill="#809da1" stroke="#243f4b" stroke-width="2"/>''')
svg(Path('package.svg'),49,49,'''<ellipse cx="25" cy="44" rx="23" ry="5" fill="#112029" opacity=".5"/><path d="M5 16L29 9L45 20V40L21 48L5 36Z" fill="#a48957" stroke="#303b3a" stroke-width="3"/><path d="M5 16L21 28L45 20L29 8Z" fill="#d2b078" stroke="#3f4e4b" stroke-width="2"/><path d="M21 28V47 M18 12L35 24V44" stroke="#e2d1a1" stroke-width="4"/><path d="M27 31l12-4v7l-12 4Z" fill="#536b70"/>''')
svg(Path('cache.svg'),51,53,'''<ellipse cx="25" cy="47" rx="24" ry="5" fill="#0f242c" opacity=".5"/><path d="M6 17L30 10L46 23V42L22 51L6 38Z" fill="#466c76" stroke="#20363e" stroke-width="3"/><path d="M6 17L21 29L46 23L30 10Z" fill="#91a7a4" stroke="#29494f" stroke-width="2"/><path d="M21 29V50" stroke="#273f46" stroke-width="2"/><path d="M33 29v13 M27 36l12-4" stroke="#e1d6ac" stroke-width="4"/><path d="M20 12V6l9-2 7 5v6" fill="none" stroke="#b1c4bc" stroke-width="3"/>''')

# Recruit cutout master: wider hood/poncho, short work boots, satchel. The canvas
# and non-overlapping part boundaries are shared by each exported directional rig.
views={}
for facing in ['toward','away','side']:
    side=facing=='side'; away=facing=='away'
    parts={}
    if side:
        parts['far_leg']='<path d="M54 108L67 110L65 140L67 162L54 169L46 165L52 146Z" fill="url(#suit)" stroke="#23333c" stroke-width="3"/><path d="M53 158L66 156L69 169L52 172L45 167Z" fill="#293a43" stroke="#1d2b33" stroke-width="3"/>'
        parts['near_leg']='<path d="M64 110L81 110L79 140L74 165L58 166L64 143Z" fill="url(#suit)" stroke="#23333c" stroke-width="3"/><path d="M60 157L76 158L76 165L91 168L90 173H60Z" fill="#3c4f57" stroke="#1d2c34" stroke-width="3"/><path d="M67 135h9" stroke="#a4ad9b" stroke-width="2"/>'
        parts['far_arm']='<path d="M59 58L65 79L60 104L50 108L48 101L53 79L48 61Z" fill="#4a616b" stroke="#263842" stroke-width="3"/>'
        parts['near_arm']='<path d="M75 63L85 66L85 88L78 112L68 113L64 105L73 86Z" fill="url(#suit)" stroke="#22353f" stroke-width="3"/><path d="M70 103l10 4-3 10-8 2-6-9Z" fill="#ae8e70" stroke="#253b44" stroke-width="2"/><path d="M72 92l10 3" stroke="#b4baa3" stroke-width="3"/>'
        parts['torso']='<path d="M48 54L72 54L84 67L80 110L59 119L46 108Z" fill="url(#suit)" stroke="#273943" stroke-width="3"/><path d="M49 55L73 53L85 68L83 91L69 86L54 94L44 84Z" fill="url(#coat)" stroke="#443f36" stroke-width="3"/><path d="M53 64L66 78L77 61 M53 83l17-9" fill="none" stroke="#dec39a" stroke-width="2"/><path d="M45 66L55 70V104L44 110L39 99V76Z" fill="#506f79" stroke="#253c48" stroke-width="3"/><path d="M44 76l8 2 M44 89l8-2" stroke="#a1b6b3" stroke-width="2"/><path d="M68 95L81 94L83 111L69 115Z" fill="#3c6270" stroke="#233943" stroke-width="2"/>'
        parts['head']='<path d="M45 25L52 14L68 11L80 19L82 37L75 57L57 59L46 47Z" fill="#6a7f81" stroke="#253740" stroke-width="3"/><path d="M65 22L81 25L80 33L89 37L82 43L80 50L66 53L59 44V31Z" fill="#b99678" stroke="#343e3e" stroke-width="2"/><path d="M45 28L52 17L69 14L79 21L63 24L57 39L57 54L45 48Z" fill="#9dad9f" stroke="#354f57" stroke-width="2"/><path d="M68 28L81 29L80 36L69 36Z" fill="#304653" stroke="#dfcaa1" stroke-width="2"/><path d="M73 30h5" stroke="#9ac3ca" stroke-width="2"/><path d="M71 44h9" stroke="#665344" stroke-width="2"/>'
    else:
        parts['far_leg']='<path d="M44 105L61 109L61 137L55 166L39 166L43 139Z" fill="url(#suit)" stroke="#23353f" stroke-width="3"/><path d="M41 155L57 158L56 171L34 172L34 167Z" fill="#334650" stroke="#1c2b34" stroke-width="3"/><path d="M43 137l15 2" stroke="#a1afa4" stroke-width="2"/>'
        parts['near_leg']='<path d="M64 109L82 105L87 139L84 166L69 167L68 141Z" fill="url(#suit)" stroke="#23353f" stroke-width="3"/><path d="M70 157L85 155L89 167L90 172H68Z" fill="#334650" stroke="#1c2b34" stroke-width="3"/><path d="M71 139l13-2" stroke="#a1afa4" stroke-width="2"/>'
        parts['far_arm']='<path d="M37 61L47 67L40 87L39 108L28 111L25 103L29 83Z" fill="url(#suit)" stroke="#21343e" stroke-width="3"/><path d="M29 103l10 2-1 12-6 3-7-7Z" fill="#b69678" stroke="#283c43" stroke-width="2"/><path d="M29 94l11 1" stroke="#adb9a6" stroke-width="3"/>'
        parts['near_arm']='<path d="M82 61L93 64L99 85L100 108L89 113L86 103L85 85Z" fill="url(#suit)" stroke="#21343e" stroke-width="3"/><path d="M90 105l10-1 4 10-6 6-8-2Z" fill="#b69678" stroke="#283c43" stroke-width="2"/><path d="M88 96l11-2" stroke="#adb9a6" stroke-width="3"/>'
        parts['torso']='<path d="M39 58L80 56L91 77L83 117L64 124L40 114L36 80Z" fill="url(#suit)" stroke="#22343e" stroke-width="3"/><path d="M39 52L81 52L95 73L92 90L74 91L64 104L49 91L29 86L32 70Z" fill="url(#coat)" stroke="#443e34" stroke-width="3"/><path d="M37 77L50 84L64 98L77 84L91 78 M39 65L64 86L86 64" fill="none" stroke="#dac09a" stroke-width="2"/>'
        if away:
            parts['torso']+='<path d="M47 67L74 64L85 78L80 105L49 110L41 93Z" fill="#50727b" stroke="#293e48" stroke-width="3"/><path d="M47 72L76 68L80 81L49 87Z" fill="#87a29f" stroke="#365763" stroke-width="2"/><path d="M57 70v35 M51 92l24-3" stroke="#b6b393" stroke-width="3"/>'
            parts['head']='<path d="M43 26L49 14L66 9L80 17L85 34L80 51L63 60L46 51L39 37Z" fill="#7e9594" stroke="#283d46" stroke-width="3"/><path d="M47 24L51 16L66 13L77 20L79 40L63 50L48 40Z" fill="#a4b3a5"/><path d="M64 16V46 M44 36L64 52L81 38" fill="none" stroke="#59787d" stroke-width="2"/><path d="M48 52L63 59L80 50" fill="none" stroke="#d2bea0" stroke-width="4"/>'
        else:
            parts['torso']+='<path d="M80 58L46 105" stroke="#283a43" stroke-width="8"/><path d="M80 58L46 105" stroke="#aeac89" stroke-width="4"/><path d="M39 94L60 99L58 119L37 113Z" fill="#497482" stroke="#203c48" stroke-width="3"/><path d="M40 98l18 4-3 8-17-5Z" fill="#7b9e9e"/><path d="M47 103v7" stroke="#d6c598" stroke-width="3"/>'
            parts['head']='<path d="M41 27L48 15L63 9L78 14L85 27L83 46L70 58L55 58L42 47L37 34Z" fill="#809792" stroke="#283d46" stroke-width="3"/><path d="M46 28L52 21L72 21L79 29L76 47L67 54L56 51L47 42Z" fill="#b79778" stroke="#35433f" stroke-width="2"/><path d="M42 30L48 17L63 12L78 17L83 30L74 27L68 22L55 24L48 32Z" fill="#a9b6a6" stroke="#4c696c" stroke-width="2"/><path d="M47 29L78 28L76 38L49 38Z" fill="#304954" stroke="#d9c59e" stroke-width="2"/><path d="M50 32L60 32 M66 32L74 31" stroke="#99c1ca" stroke-width="2"/><path d="M60 45l9 1" stroke="#735841" stroke-width="2"/><path d="M43 46L56 57L69 60L82 48" fill="none" stroke="#d0ba98" stroke-width="4"/>'
    views[facing]=parts
    for part,body in parts.items(): svg(Path('recruit')/facing/f'{part}.svg',128,180,body)
    # Editable composite master; each part remains an identified group.
    composite=''.join(f'<g id="{p}">{parts[p]}</g>' for p in ['far_arm','far_leg','near_leg','torso','head','near_arm'])
    svg(Path('recruit')/f'{facing}_master.svg',128,180,composite)
print('Wrote',len(list(OUT.rglob('*.svg'))),'original vector illustrations/cutouts')
