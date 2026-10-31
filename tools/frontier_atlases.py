"""Measure alpha bounds and record frame/foot anchors; never alter source pixels."""
import json
from pathlib import Path
import numpy as np
from scipy import ndimage
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
HEIGHTS={'carry_log':315,'carry_spoils':322,'work':356,'overpower':340,'great_beast':272,'spearmen':313,'clinch':245,'player_maul':300}
ANCHORS={
 'overpower':[(156,506),(604,507),(951,508),(1263,508),(184,951),(575,951),(915,953),(1260,953)],
 'clinch':[(105,477),(520,476),(901,478),(1311,483),(117,925),(519,928),(1047,933),(1242,933)],
 'player_maul':[(148,405),(462,404),(747,409),(1114,406),(154,804),(460,803),(759,801),(1113,803),(157,1178),(465,1180),(759,1195),(1117,1177)],
 'spearmen':[(164,492),(547,491),(930,489),(1283,487),(186,893),(526,893),(924,883),(1330,893)]
}
for name,height in HEIGHTS.items():
 image=Image.open(ROOT/'assets/frontier'/f'{name}.png');a=np.asarray(image)[:,:,3]
 assert float((a<6).mean())>.25, f'{name} lacks usable transparency'
 labels,n=ndimage.label(a>100);bounds=[]
 for k,sl in enumerate(ndimage.find_objects(labels),1):
  if sl is not None and (labels[sl]==k).sum()>1200:
   y,x=sl;bounds.append([x.start,y.start,x.stop-x.start,y.stop-y.start])
 count=8 if name in ('overpower','spearmen','clinch') else 12
 assert len(bounds)==count,(name,len(bounds))
 bounds.sort(key=lambda r:r[1]+r[3]);ordered=[]
 for row in range(count//4):ordered.extend(sorted(bounds[row*4:row*4+4],key=lambda r:r[0]))
 frames=[]
 for i,(x,y,w,h) in enumerate(ordered):
  ax,ay=ANCHORS.get(name,[(r[0]+r[2]/2,r[1]+r[3]-2) for r in ordered])[i]
  # Up to 2px alpha outline padding, safely inside the image.
  x0=max(0,x-2);y0=max(0,y-2);x1=min(image.width,x+w+2);y1=min(image.height,y+h+2)
  frames.append([x0,y0,x1-x0,y1-y0,round(ax-x0,2),round(ay-y0,2)])
 (ROOT/'resources/frontier'/f'{name}.json').write_text(json.dumps({'height':height,'frames':frames},indent=2)+'\n')
 print(name,len(frames),'frames, alpha and bounds verified')
