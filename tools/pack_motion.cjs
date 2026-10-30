// Packs generated whole-body illustrations without rigging or deforming limbs.
// Requires sharp. Source alpha is preserved; small disconnected neighbouring
// fragments are excluded when the source atlas has uneven gutters.
const sharp=require('sharp'), fs=require('fs'), path=require('path');
const root=path.resolve(__dirname,'..'), src=root+'/assets/motion/source/';
async function frame(file, box, anchor, factor, flip=false){
 const {data,info}=await sharp(src+file+'.png').extract({left:box[0],top:box[1],width:box[2]-box[0],height:box[3]-box[1]}).ensureAlpha().raw().toBuffer({resolveWithObject:true});
 const w=info.width,h=info.height,seen=new Uint8Array(w*h);let largest=[];
 for(let p=0;p<w*h;p++){
  if(seen[p]||data[p*4+3]<64)continue;
  let q=[p];seen[p]=1;
  for(let i=0;i<q.length;i++){let v=q[i],x=v%w,y=Math.floor(v/w);for(let u of [x>0?v-1:-1,x<w-1?v+1:-1,y>0?v-w:-1,y<h-1?v+w:-1])if(u>=0&&!seen[u]&&data[u*4+3]>=64){seen[u]=1;q.push(u);}}
  if(q.length>largest.length)largest=q;
 }
 const mask=new Uint8Array(w*h);
 for(const p of largest){let x=p%w,y=Math.floor(p/w);for(let yy=Math.max(0,y-1);yy<=Math.min(h-1,y+1);yy++)for(let xx=Math.max(0,x-1);xx<=Math.min(w-1,x+1);xx++)mask[yy*w+xx]=1;}
 for(let p=0;p<w*h;p++)if(!mask[p])data[p*4+3]=0;
 const rw=Math.round(w*factor),rh=Math.round(h*factor);
 let buf=await sharp(data,{raw:info}).resize(rw,rh).png().toBuffer();
 const left=Math.round(256-(anchor[0]-box[0])*factor),top=Math.round(400-(anchor[1]-box[1])*factor);
 if(left<0||top<0||left+rw>512||top+rh>448)throw new Error(file+' frame outside canvas');
 let out=sharp({create:{width:512,height:448,channels:4,background:'#00000000'}}).composite([{input:buf,left,top}]);
 buf=await out.png().toBuffer();return flip?await sharp(buf).flop().png().toBuffer():buf;
}
async function pack(name,rows){
 let layers=[],rects=[];
 for(let d=0;d<4;d++){let row=d===0?0:d===3?2:1;rects[d]=[];for(let i=0;i<4;i++){
 const a=rows[row][i],b=await frame(a[0],a[1],a[2],a[3],d===1);layers.push({input:b,left:i*512,top:d*448});rects[d].push([i*512,d*448,512,448,400]);}}
 await sharp({create:{width:2048,height:1792,channels:4,background:'#00000000'}}).composite(layers).png().toFile(root+'/assets/motion/'+name+'.png');
 fs.writeFileSync(root+'/resources/'+name+'.json',JSON.stringify(rects));
}
(async()=>{
 for(const outfit of ['leather','iron']){
  let rows=[]; const ys=[0,337,668,1024];
  for(let r=0;r<3;r++){rows[r]=[];for(let c=0;c<4;c++)rows[r].push(['walk_'+outfit,[c*384,ys[r],(c+1)*384,ys[r+1]],[c*384+(r===1?[203,183,207,197][c]:192),[334,668,1016][r]],0.84]);}
  await pack('stride_'+outfit,rows);
  const idleRows=[];for(let r=0;r<3;r++){let y=outfit==='leather'?0:484;idleRows[r]=[];for(let c=0;c<4;c++)idleRows[r].push(['idle',[r*512,y,(r+1)*512,outfit==='leather'?484:1024],[r*512+[275,263,245][r],outfit==='leather'?480:990],280/(outfit==='leather'?475:500)]);}
  await pack('rest_'+outfit,idleRows);
  let boxes=outfit==='leather'?[[[39,29,326,402],[397,6,670,402],[745,136,1061,440],[1124,110,1436,413]],[[67,401,289,733],[446,389,659,733],[743,493,1100,748],[1118,473,1436,751]],[[32,731,315,1075],[397,729,668,1075],[750,795,1096,1075],[1148,783,1429,1074]]]:[[[37,25,329,393],[391,4,668,393],[742,123,1060,425],[1130,98,1438,398]],[[60,394,294,726],[435,390,666,728],[737,476,1102,736],[1121,459,1444,737]],[[31,724,321,1066],[402,721,676,1066],[745,783,1101,1067],[1146,770,1438,1066]]];
  let feet=outfit==='leather'?[401,731,1073]:[391,726,1064]; rows=[];
  for(let r=0;r<3;r++){rows[r]=[];for(let c=0;c<4;c++)rows[r].push(['attack_'+outfit,boxes[r][c],[[210,550,865,1240][c],feet[r]],[0.95,1.05,0.97][r]]);}
  await pack('strike_'+outfit,rows);
 }
 console.log('Packed six atlases with fixed pelvis/ground anchors.');
})();
