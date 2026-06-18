cmd.scene('''scene_003''')
cmd.disable('OBJ01_SPIKE_obj')
cmd.disable('OBJ01_SPIKE_headA_obj')
zoom OBJ01_HC-CDR2
cmd.enable('OBJ01_PRINT_AB1',1)
cmd.hide("surface"   ,"OBJ01_PRINT_AB1")
cmd.disable('OBJ01_AB1_obj')
cmd.show("cartoon"   ,"OBJ01_PRINT_AB1")
scene scene_003_02, store
scene scene_003_02
select OBJ01_colliers, (OBJ01_PRINT_AB1 and resi 47-74 and chain H)
cmd.show("cartoon"   ,"OBJ01_colliers")

select OBJ01_colliers_sc, OBJ01_colliers and (resi 47 or resi 57 resi 64)
cmd.show("sticks","((byres (OBJ01_colliers_sc))&(sc.|(n. CA|n. N&r. PRO)))")
cmd.hide("(OBJ01_colliers_sc and hydro)")
select OBJ01_colliers_ca, OBJ01_colliers and (resi 51 or resi 58) and name ca
cmd.show("spheres"   ,"OBJ01_colliers_ca")
set sphere_scale, 0.5, OBJ01_PRINT_AB1, 

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
load emd_52789.map, OBJ01_map_norm

cmd.volume_ramp_new('map_colors', [\
      7.50, 1.00, 1.00, 1.00, 0.00, \
      9.00, 0.25, 0.90, 0.96, 0.40, \
     12.00, 0.29, 0.92, 0.97, 0.00, \
     12.00, 0.29, 0.31, 0.97, 0.57, \
     50.76, 0.04, 0.04, 0.34, 0.00, \
    ])
volume OBJ01_Vol, OBJ01_map_norm, map_colors

## loaded as non-normalized

set normalize_ccp4_maps, 0
load emd_52789.map, OBJ01_map_nonnorm

cmd.volume_ramp_new('map_colors_nonnorm', [\
      5.00, 1.00, 1.00, 1.00, 0.00, \
      7.00, 0.25, 0.90, 0.96, 0.40, \
     9.00, 0.29, 0.92, 0.97, 0.00, \
     9.00, 0.29, 0.31, 0.97, 0.57, \
     50.76, 0.04, 0.04, 0.34, 0.00, \
    ])

volume OBJ01_Vol_nonnorm, OBJ01_map_nonnorm, map_colors

create OBJ01_colliers_Dobj, OBJ01_colliers
cmd.disable('5i19_colliers_ca_obj')
util.color_deep("black", 'OBJ01_colliers_Dobj', 0)
cmd.disable('OBJ01_PRINT_AB1')
cmd.hide("everything","OBJ01_colliers_Dobj")
cmd.show("lines"     ,"OBJ01_colliers_Dobj")
cmd.hide("(OBJ01_colliers_Dobj and hydro)")
scene scene_003_06, store
create OBJ01_Dobj, OBJ01
cmd.scene('''scene_003_06''')
cmd.enable('OBJ01_Dobj',1)
cmd.hide("everything","OBJ01_Dobj")
util.color_deep("black", 'OBJ01_Dobj', 0)
cmd.show("lines"     ,"OBJ01_Dobj")
cmd.hide("(OBJ01_Dobj and hydro)")
cmd.show("sticks"    ,"OBJ01_colliers_Dobj")
cmd.hide("(OBJ01_colliers_Dobj and hydro)") 

set_view (\
     0.867069066,    0.491434932,   -0.081704386,\
    -0.431184143,    0.658144951,   -0.617183089,\
    -0.249528155,    0.570367515,    0.782562673,\
     0.000301681,   -0.006019346,  -83.925254822,\
   262.762695312,  267.535705566,  163.875701904,\
    79.332687378,   88.747940063,   20.000000000 )

scene scene_003_06, store
