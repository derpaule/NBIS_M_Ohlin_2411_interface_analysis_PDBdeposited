cmd.scene('''scene_003''')
load 9tk0_mm.cif, OBJ01_mm
cmd.disable('OBJ01_AB1_obj')
cmd.disable('OBJ01_SPIKE_obj')
cmd.disable('OBJ01_SPIKE_headA_obj')

create OBJ01_mm_PRINT_AB1, OBJ01_mm and (chain H or chain L)
create OBJ01_mm_PRINT_AG, OBJ01_mm and (chain A)
cmd.color_deep("palegreen", 'OBJ01_mm_PRINT_AB1', 0)
findseq GFTFSYSG, OBJ01_mm_PRINT_AB1 and chain H, OBJ01_mm_HC-CDR1;
findseq IYGGSGST, OBJ01_PRINT_AB1 and chain H, OBJ01_mm_HC-CDR2;
findseq ARDYSYLDY, OBJ01_PRINT_AB1 and chain H, OBJ01_mm_HC-CDR3;
cmd.color_deep("paleyellow", 'OBJ01_mm_HC-CDR1', 0);
cmd.color_deep("lightorange", 'OBJ01_mm_HC-CDR2', 0);
cmd.color_deep("lightpink", 'OBJ01_mm_HC-CDR3', 0);
cmd.disable('OBJ01_mm')
set_view (\
     0.867069066,    0.491434932,   -0.081704386,\
    -0.431184143,    0.658144951,   -0.617183089,\
    -0.249528155,    0.570367515,    0.782562673,\
     0.000301681,   -0.006019346,  -83.925254822,\
   262.762695312,  267.535705566,  163.875701904,\
    79.332687378,   88.747940063,   20.000000000 )

scene scene_003_02, store
select OBJ01_mm_colliers, (OBJ01_mm_PRINT_AB1 and resi 47-74 and chain H)
cmd.show("cartoon"   ,"OBJ01_mm_colliers")

select OBJ01_mm_colliers_sc, OBJ01_mm_colliers and (resi 47 or resi 57 resi 64)
cmd.show("sticks","((byres (OBJ01_mm_colliers_sc))&(sc.|(n. CA|n. N&r. PRO)))")
cmd.hide("(OBJ01_mm_colliers_sc and hydro)")
select OBJ01_mm_colliers_ca, OBJ01_mm_colliers and (resi 51 or resi 58) and name ca
cmd.show("spheres"   ,"OBJ01_mm_colliers_ca")
set sphere_scale, 0.5, OBJ01_mm_PRINT_AB1, 

set_view (\
     0.867069066,    0.491434932,   -0.081704386,\
    -0.431184143,    0.658144951,   -0.617183089,\
    -0.249528155,    0.570367515,    0.782562673,\
     0.000301681,   -0.006019346,  -83.925254822,\
   262.762695312,  267.535705566,  163.875701904,\
    79.332687378,   88.747940063,   20.000000000 )

scene scene_003_03, store

### scene_003_006 density!
set normalize_ccp4_maps, 1
load emd-56019_mm.map, OBJ01_map_norm

cmd.volume_ramp_new('map_colors', [\
      18.00, 1.00, 1.00, 1.00, 0.00, \
      21.00, 0.25, 0.90, 0.96, 0.40, \
     24.00, 0.29, 0.92, 0.97, 0.00, \
     24.00, 0.29, 0.31, 0.97, 0.57, \
     100, 0.04, 0.04, 0.34, 0.00, \
    ])

volume OBJ01_Vol, OBJ01_map_norm, map_colors

## loaded as non-normalized

set normalize_ccp4_maps, 0
load emd-56019_mm.map, OBJ01_map_nonnorm

cmd.volume_ramp_new('map_colors_non', [\
      4.50, 1.00, 1.00, 1.00, 0.00, \
      6.00, 0.25, 0.90, 0.96, 0.40, \
     7.50, 0.29, 0.92, 0.97, 0.00, \
     7.50, 0.29, 0.31, 0.97, 0.57, \
     50.76, 0.04, 0.04, 0.34, 0.00, \
    ])

volume OBJ01_Vol_nonnorm, OBJ01_map_nonnorm, map_colors_non
##

create OBJ01_mm_colliers_Dobj, OBJ01_mm_colliers
util.color_deep("black", 'OBJ01_mm_colliers_Dobj', 0)
cmd.disable('OBJ01_mm_PRINT_AB1')
cmd.hide("everything","OBJ01_mm_colliers_Dobj")
cmd.show("lines"     ,"OBJ01_mm_colliers_Dobj")
cmd.hide("(OBJ01_mm_colliers_Dobj and hydro)")
scene scene_003_06, store
create OBJ01_mm_Dobj, OBJ01_mm
cmd.scene('''scene_003_06''')
cmd.enable('OBJ01_mm_Dobj',1)
cmd.hide("everything","OBJ01_mm_Dobj")
util.color_deep("black", 'OBJ01_mm_Dobj', 0)
cmd.show("lines"     ,"OBJ01_mm_Dobj")
cmd.hide("(OBJ01_mm_Dobj and hydro)")
cmd.show("sticks"    ,"OBJ01_mm_colliers_Dobj")
cmd.hide("(OBJ01_mm_colliers_Dobj and hydro)") 

set_view (\
     0.867069066,    0.491434932,   -0.081704386,\
    -0.431184143,    0.658144951,   -0.617183089,\
    -0.249528155,    0.570367515,    0.782562673,\
     0.000301681,   -0.006019346,  -83.925254822,\
   262.762695312,  267.535705566,  163.875701904,\
    79.332687378,   88.747940063,   20.000000000 )

scene scene_003_06, store
