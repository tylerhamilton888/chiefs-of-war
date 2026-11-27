"""Project the painted iron around its haft socket for the four camera directions.

Each textured surface uses the existing item's painted pixels. The shallow axe
wedge and the square maul have different cross sections when seen end-on.
"""
import math

import numpy as np
from PIL import Image

CELL = (96, 104)
SOCKET = (20, 51)
SAMPLES = 3
# In front the Ogre presents the broad face. In profile the near and far ends
# turn toward opposite sides of the camera. Rear shows the far cheek.
ANGLES = (0, 60, -34, -58)


def axe_mesh(image):
    mask = np.asarray(image)[:, :, 3] > 105
    rows = np.flatnonzero(mask.any(axis=1))
    faces = []
    previous = None
    for y in rows:
        extent = np.flatnonzero(mask[y])
        xs = np.linspace(extent[0], extent[-1], 7)
        ring = []
        for sign, line in [(1, xs), (-1, xs[::-1])]:
            for x in line:
                # The blade narrows to an edge. The eye around the haft is thick.
                thickness = 0.8 + 6.4 * max(0, 1 - x / 41) ** 1.6
                ring.append(((x, y - 43, sign * thickness), (x, y)))
        if previous is not None:
            for i in range(len(ring)):
                j = (i + 1) % len(ring)
                shade = 1.0 if i < 6 else 0.81 if i in (6, 13) else 0.94
                quad = [previous[i], previous[j], ring[j], ring[i]]
                if i in (6, 13):
                    # The outline pixel is black ink. Sample just inside it for the
                    # thickness of the steel, leaving the original ink on the cheek.
                    step = -2 if i == 6 else 2
                    quad = [(pt, (min(42, max(0, uv[0] + step)), uv[1])) for pt, uv in quad]
                faces.append((quad, shade))
        previous = ring
    return faces


def maul_mesh():
    # Map the long cheek, square end, top bevel and collar independently. Turning
    # toward the camera reveals the end face instead of stretching the cheek.
    faces = []
    def quad(points, uv, light):
        faces.append((list(zip(points, uv)), light))

    x0, x1, z = 10, 42, 11
    top, bottom = -23, 24
    side_uv = [(11, 23), (32, 17), (33, 68), (11, 65)]
    end_uv = [(33, 17), (45, 23), (46, 64), (33, 69)]
    for depth, light in [(z, 1.0), (-z, 0.84)]:
        quad([(x0,top,depth),(x1,top,depth),(x1,bottom,depth),(x0,bottom,depth)], side_uv, light)
    for x, light in [(x0, 0.86), (x1, 1.08)]:
        quad([(x,top,z),(x,top,-z),(x,bottom,-z),(x,bottom,z)], end_uv, light)
    for y, light in [(top,1.22),(bottom,0.68)]:
        quad([(x0,y,-z),(x1,y,-z),(x1,y,z),(x0,y,z)],
             [(10,23),(36,15),(45,22),(16,28)], light)
    for i in range(12):
        a, b = [math.tau * j / 12 for j in (i, i+1)]
        quad([(x, 7*math.sin(t), 7*math.cos(t)) for x,t in [(0,a),(12,a),(12,b),(0,b)]],
             [(x,43+6*math.sin(t)) for x,t in [(1,a),(9,a),(9,b),(1,b)]],
             0.9 + 0.12 * math.cos(a))
    return faces


def project(image, faces, degrees):
    w, h = CELL
    canvas = np.zeros((h*SAMPLES,w*SAMPLES,4), dtype=np.uint8)
    depth = np.full(canvas.shape[:2], -np.inf)
    ink = np.asarray(image)
    yaw = math.radians(degrees)
    c, s = math.cos(yaw), math.sin(yaw)
    for face, light in faces:
        xyz, uv = map(np.asarray, zip(*face))
        x, y, z = xyz.T
        d = x*s + z*c
        coord = np.column_stack(((SOCKET[0] + x*c - z*s)*SAMPLES,
                                 (SOCKET[1] + y + 0.25*d)*SAMPLES, d))
        for indices in ([0,1,2], [0,2,3]):
            a,b,k = coord[indices]
            left,top = np.maximum(np.floor(coord[indices,:2].min(axis=0)).astype(int), 0)
            right,base = np.minimum(np.ceil(coord[indices,:2].max(axis=0)).astype(int)+1, (w*SAMPLES,h*SAMPLES))
            xx, yy = np.meshgrid(np.arange(left,right)+0.5-a[0],np.arange(top,base)+0.5-a[1])
            ex,ey = b[:2]-a[:2]
            fx,fy = k[:2]-a[:2]
            det = ex*fy - ey*fx
            if abs(det) < 1e-7:
                continue
            u,v = (xx*fy-yy*fx)/det, (yy*ex-xx*ey)/det
            weight = np.stack((1-u-v,u,v),axis=-1)
            zz = weight @ coord[indices,2]
            buf = depth[top:base,left:right]
            valid = (weight.min(axis=-1) >= -1e-7) & (zz > buf)
            if not valid.any():
                continue
            tex = np.rint(weight[valid] @ uv[indices]).astype(int)
            color = ink[tex[:,1],tex[:,0]].copy()
            color[:,:3] = np.clip(color[:,:3]*light,0,255)
            canvas[top:base,left:right][valid] = color
            buf[valid] = zz[valid]
    return Image.fromarray(canvas).resize(CELL, Image.Resampling.LANCZOS)


def turn_sheet(head, weapon):
    faces = axe_mesh(head) if weapon == "hunting_axe" else maul_mesh()
    atlas = Image.new("RGBA",(CELL[0]*len(ANGLES), CELL[1]))
    for i,yaw in enumerate(ANGLES):
        if i == 0:
            atlas.alpha_composite(head,(SOCKET[0],SOCKET[1]-43))
        else:
            atlas.alpha_composite(project(head,faces,yaw),(CELL[0]*i,0))
    return atlas
