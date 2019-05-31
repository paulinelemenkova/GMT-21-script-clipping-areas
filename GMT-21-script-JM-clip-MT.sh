#!/bin/bash
# Purpose: Clipping of raster image using coastlines
# GMT modules: gmtset, gmtdefaults, grd2cpt, grdimage, pscoast, makecpt, grdcontour, psbasemap, psscale, logo, psconvert
# Unix progs: rm
# Step-1. Generate a file
ps=GMT_clip_KKT.ps

# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN dimgray \
    MAP_FRAME_WIDTH 0.1c \
    MAP_TITLE_OFFSET 1.5c \
    MAP_ANNOT_OFFSET 0.1c \
    MAP_TICK_PEN_PRIMARY thinnest,dimgray \
    MAP_GRID_PEN_PRIMARY thin,dimgray \
    MAP_GRID_PEN_SECONDARY thinnest,dimgray \
    FONT_TITLE 12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY 7p,Palatino-Roman,dimgray \
    FONT_LABEL 7p,Palatino-Roman,dimgray \

# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Step-4. Generate geoid image with coloring
gmt grd2cpt geoid.egm96.grd -Chaxby > geoid.cpt
gmt grdimage geoid.egm96.grd -I+a45+nt1 -R140/170/40/60 -JM6.5i -Cgeoid.cpt -P -K > $ps

# Step-5. Use gmt pscoast to initiate clip path for land
gmt pscoast -R140/170/40/60 -J -Dh -Gc -O -K >> $ps

# Step-6. Generate topography image w/shading
gmt makecpt -C150 -T-10000,2000 -N > shade.cpt
gmt grdimage geoid.egm96.grd -I+a45+nt1 -R -J -Cshade.cpt -O -K >> $ps

# Step-7. Undo clipping and overlay basemap
gmt pscoast -R -J -O -K -Q -B+t"Color geoid image of the Kuril-Kamchatka Trench with gray-shaded topography of the clipped land areas" >> $ps

# Step-8. Add shorelines
gmt grdcontour kkt_relief.nc -R -J -C1000 -O -K >> $ps

# Step-9. Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f3a3 -Bsxg4 -Bsyg3 -O -K >> $ps

# Step-10. Put a color legend on top of the land mask
gmt psscale -DjTC+o0.8c/-1.6c+w12c/0.5c+h -R -J -Cgeoid.cpt -Bx10f1 -By+lmGal -I -O -K >> $ps

# Step-11. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx1.0c/13.3c+w0.3i+f2+l+o0.15i \
    -Lx5.3i/-0.5i+c50+w500k+l"Mercator projection. Scale (km)"+f \
    -UBL/-15p/-40p -O -K >> $ps

# Step-12. Add GMT logo
gmt logo -Dx6.2/-2.2+o0.1i/0.1i+w2c -O >> $ps

# Step-14. Convert to image file using GhostScript
gmt psconvert GMT_clip_KKT.ps -A0.2c -E720 -Tj -P -Z

# Step-15. Clean up
rm -f geoid.cpt shade.cpt
