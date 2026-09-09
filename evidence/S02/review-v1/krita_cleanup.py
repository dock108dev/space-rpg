"""Run inside Krita Scripter. Retains originals; authors separated editable layers."""
from krita import Krita, InfoObject
from PyQt5.QtGui import QImage,QPainter,QPolygonF,QColor
from PyQt5.QtCore import QPointF,Qt,QByteArray
from pathlib import Path
import json,time,traceback
ROOT=Path('/Users/michaelfuscoletti/Desktop/space-opera-rpg')
OUT=ROOT/'source-assets/S02'
records=[]
def run():
 for facing in ['toward','away','side']:
  start=time.monotonic()
  src=OUT/'originals'/('human-'+facing+'-v1.png')
  original=Krita.instance().openDocument(str(src)); original.waitForDone()
  w,h=original.width(),original.height()
  raw=bytearray(original.pixelData(0,0,w,h))
  # Deliberately dark costume permits bright neutral-background removal, including inter-limb holes.
  removed=0
  for i in range(0,len(raw),4):
   b,g,r=raw[i:i+3]
   if min(r,g,b)>205 and max(r,g,b)-min(r,g,b)<30:
    raw[i+3]=0;removed+=1
  clean=QImage(bytes(raw),w,h,QImage.Format_ARGB32).copy()
  # Coordinates are authored against normalized 1254-square source, side scales to square below.
  clean=clean.scaled(1254,1254,Qt.IgnoreAspectRatio,Qt.SmoothTransformation)
  w=h=1254
  if facing=='side':
   polys={
    'far_leg':[(535,540),(704,530),(755,1182),(504,1182)],
    'near_leg':[(518,536),(652,539),(719,1240),(484,1240)],
    'torso':[(497,176),(668,196),(713,555),(521,602),(490,410)],
    'head':[(495,10),(725,10),(725,219),(520,215)],
    'far_arm':[(500,235),(580,235),(633,675),(537,681)],
    'near_arm':[(485,232),(579,237),(654,681),(556,695),(495,540)]}
   pivots={'far_leg':[594,556],'near_leg':[578,556],'torso':[600,540],'head':[600,202],'far_arm':[545,265],'near_arm':[545,265]}
   foot=[603,1176];top=34
  else:
   back=facing=='away'
   polys={
    'far_leg':[(495,554),(641,552),(636,700),(591,1230),(375,1230),(459,782)],
    'near_leg':[(622,551),(739,552),(784,809),(850,1230),(665,1230),(622,702)],
    'far_arm':[(462,245),(509,275),(502,459),(476,588),(471,717),(392,729),(374,575),(405,400)],
    'near_arm':[(740,247),(786,253),(852,480),(865,715),(782,716),(759,575),(727,424)],
    'torso':[(468,240),(558,196),(690,189),(771,252),(738,460),(751,583),(492,584),(505,440)],
    'head':[(527,14),(708,14),(725,202),(688,257),(554,257),(524,195)]}
   if back: polys['head']=[(524,9),(713,9),(721,176),(690,210),(548,214),(526,175)]
   pivots={'far_leg':[555,580],'near_leg':[688,580],'far_arm':[478,274],'near_arm':[759,274],'torso':[623,551],'head':[624,219]}
   foot=[623,1180];top=34
  doc=Krita.instance().createDocument(w,h,'human-'+facing,'RGBA','U8','sRGB-elle-V2-srgbtrc.icc',72)
  doc.setBatchmode(True)
  for initial in doc.rootNode().childNodes(): initial.remove()
  ref=doc.createNode('REFERENCE original - hidden','paintlayer');doc.rootNode().addChildNode(ref,None)
  ref.setPixelData(QByteArray(bytes(raw)),0,0,original.width(),original.height());ref.setVisible(False)
  layers=[]
  for name,coords in polys.items():
   img=QImage(w,h,QImage.Format_ARGB32);img.fill(Qt.transparent)
   paint=QPainter(img);paint.setRenderHint(QPainter.Antialiasing)
   # Overlapping hidden joint coverage, drawn below sampled illustration.
   if False:

    paint.setPen(Qt.NoPen);paint.setBrush(QColor('#343630'));px,py=pivots[name];paint.drawEllipse(QPointF(px,py),55,45)
   if False:

    paint.setPen(Qt.NoPen);paint.setBrush(QColor('#665e43'));px,py=pivots[name];paint.drawEllipse(QPointF(px,py),35,33)
   paint.setClipRegion(__import__('PyQt5.QtGui',fromlist=['QRegion']).QRegion(QPolygonF([QPointF(x,y) for x,y in coords]).toPolygon()))
   paint.drawImage(0,0,clean);paint.end()
   node=doc.createNode(name,'paintlayer');doc.rootNode().addChildNode(node,None)
   node.setPixelData(QByteArray(img.bits().asstring(w*h*4)),0,0,w,h);layers.append(node)
  doc.refreshProjection();doc.waitForDone()
  master=OUT/'masters'/('human-'+facing+'.kra');assert doc.saveAs(str(master))
  config=InfoObject();config.setProperty('alpha',True);config.setProperty('forceSRGB',True)
  dest=ROOT/'game/art/human'/facing;dest.mkdir(parents=True,exist_ok=True)
  for node in layers:
   for other in layers:other.setVisible(other==node)
   doc.refreshProjection();doc.waitForDone()
   assert doc.exportImage(str(dest/(node.name()+'.png')),config)
  for node in layers:node.setVisible(True)
  doc.refreshProjection();doc.waitForDone();assert doc.save()
  assert doc.exportImage(str(OUT/'exports'/('human-'+facing+'-assembled.png')),config)
  check=Krita.instance().openDocument(str(master));check.waitForDone();assert len(check.rootNode().childNodes())==7;check.close()
  Krita.instance().activeWindow().addView(doc)
  original.close()
  records.append({'facing':facing,'source':str(src.relative_to(ROOT)),'source_dimensions':[clean.width(),clean.height()],'export_dimensions':[w,h],'foot':foot,'top':top,'pivots':pivots,'removed_background_pixels':removed,'seconds':time.monotonic()-start,'master_reopened':True})
 (OUT/'exports/human-rig.json').write_text(json.dumps(records,indent=2))
try:
 run()
 (ROOT/'evidence/S02/krita-result.txt').write_text('PASS: Krita '+Krita.instance().version()+' opened originals, authored six cutout layers per direction, saved/reopened KRA and exported RGBA PNG.\n'+json.dumps(records,indent=2))
except Exception:
 (ROOT/'evidence/S02/krita-result.txt').write_text(traceback.format_exc())
 raise
