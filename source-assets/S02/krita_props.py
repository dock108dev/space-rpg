from krita import Krita,InfoObject
from PyQt5.QtGui import QImage
from PyQt5.QtCore import Qt,QByteArray
from pathlib import Path
import json,time,traceback
ROOT=Path('/Users/michaelfuscoletti/Desktop/space-opera-rpg');OUT=ROOT/'source-assets/S02'
def run():
 records=json.loads((OUT/'exports/props.json').read_text()) if (OUT/'exports/props.json').exists() else []
 for name in ['floor','cabinet_a','pet','creature','doorway','cabinet_b']:
  src=OUT/'originals'/(name+'-v1.png')
  if not src.exists() or any(r['asset']==name for r in records):continue
  started=time.monotonic();original=Krita.instance().openDocument(str(src));original.waitForDone()
  w,h=original.width(),original.height();raw=bytearray(original.pixelData(0,0,w,h))
  xs=[];ys=[]
  for y in range(h):
   for x in range(w):
    i=(y*w+x)*4;b,g,r=raw[i:i+3]
    if name!='floor' and min(r,g,b)>225 and max(r,g,b)-min(r,g,b)<25:raw[i+3]=0
    elif raw[i+3]>0:xs.append(x);ys.append(y)
  bounds=(min(xs),min(ys),max(xs)-min(xs)+1,max(ys)-min(ys)+1)
  img=QImage(bytes(raw),w,h,QImage.Format_ARGB32).copy(*bounds);cw,ch=img.width(),img.height()
  if name=='cabinet_b':
   doc=Krita.instance().openDocument(str(OUT/'masters/cabinet_a.kra'));doc.waitForDone()
   for node in doc.rootNode().childNodes():node.setVisible(False)
   doc.resizeImage(0,0,cw,ch);doc.setName('cabinet_b - derived from cabinet_a')
  else:
   doc=Krita.instance().createDocument(cw,ch,name,'RGBA','U8','sRGB-elle-V2-srgbtrc.icc',72)
   for node in doc.rootNode().childNodes():node.remove()
  doc.setBatchmode(True)
  n=doc.createNode('cleaned illustrated master','paintlayer');doc.rootNode().addChildNode(n,None);n.setPixelData(QByteArray(img.bits().asstring(cw*ch*4)),0,0,cw,ch)
  doc.refreshProjection();doc.waitForDone()
  master=OUT/'masters'/(name+'.kra');assert doc.saveAs(str(master))
  config=InfoObject();config.setProperty('alpha',True);config.setProperty('forceSRGB',True)
  dest=ROOT/'game/art'/name;dest.mkdir(parents=True,exist_ok=True)
  assert doc.exportImage(str(dest/'full.png'),config)
  assert doc.exportImage(str(OUT/'exports'/(name+'-master.png')),config)
  check=Krita.instance().openDocument(str(master));check.waitForDone();assert check.width()==cw;check.close()
  if name=='doorway':
   n.setVisible(False)
   pieces={'left':(0,int(ch*.26),int(cw*.25),ch-int(ch*.26)), 'right':(int(cw*.78),int(ch*.26),cw-int(cw*.78),ch-int(ch*.26)), 'lintel':(0,0,cw,int(ch*.39))}
   for part,rect in pieces.items():
    layer=doc.createNode(part,'paintlayer');doc.rootNode().addChildNode(layer,None)
    piece=img.copy(*rect);layer.setPixelData(QByteArray(piece.bits().asstring(piece.width()*piece.height()*4)),rect[0],rect[1],piece.width(),piece.height())
    doc.refreshProjection();doc.waitForDone();assert doc.exportImage(str(dest/(part+'.png')),config);layer.setVisible(False)
   for layer in doc.rootNode().childNodes():layer.setVisible(layer.name()!='cleaned illustrated master')
   doc.refreshProjection();doc.waitForDone();doc.save()
  Krita.instance().activeWindow().addView(doc);original.close()
  records.append({'asset':name,'source_dimensions':[w,h],'crop':bounds,'export_dimensions':[cw,ch],'pivot':[cw/2,ch],'cleanup_seconds':time.monotonic()-started,'master_reopened':True})
 (OUT/'exports/props.json').write_text(json.dumps(records,indent=2))
try:
 run();(ROOT/'evidence/S02/krita-props.txt').write_text('PASS: all available props saved, reopened and exported in Krita '+Krita.instance().version())
except Exception:
 (ROOT/'evidence/S02/krita-props.txt').write_text(traceback.format_exc());raise
