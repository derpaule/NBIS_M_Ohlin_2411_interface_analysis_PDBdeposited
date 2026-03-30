# Storing initial scene state
scene scene_001, store
system mkdir RBD01_scenes
system mkdir RBD01_listselections
system mkdir RBD01_output
system mkdir RBD01_input
system mkdir RBD01_output/pisarp_focus
set ambient, 0.3;
set cartoon_rect_width, 0.5;
set cartoon_rect_length, 2;
set cartoon_loop_radius, 0.5;
set cartoon_cylindrical_helices, 1;
/cmd.set('orthoscopic',1,'',0)
/cmd.set('bg_rgb',0,'',0)
run ./pymol_settings.py
viewport 800, 600

# in final script replace by fetch.

load 9ib1.cif, REF
load 9tk0.cif, OBJ01

super (OBJ01 and chain A), (REF and chain A) 

save OBJ01_aligned.pdb, OBJ01, 1, pdb

run ./listselection.py
orient OBJ01
set_view (\
     0.381232381,   -0.002290156,   -0.924476564,\
     0.918748379,   -0.110231310,    0.379143357,\
    -0.102774367,   -0.993902624,   -0.039919816,\
    -0.000117380,    0.000310242, -757.119079590,\
   244.666229248,  246.246459961,  242.255203247,\
   612.814147949,  901.409362793,   20.000000000 )

# Selections
select OBJ01_SPIKE, byres (OBJ01 and (chain A), extend 1)
select OBJ01_SPIKE, byres (OBJ01_SPIKE extend 1)
select OBJ01_SPIKE_NAGs, byres ((OBJ01_SPIKE and resn NAG) extend 1) and not (polymer.protein and backbone)
select OBJ01_AB1, OBJ01 and (chain H or chain L)

sel OBJ01_SPIKE_headsel, OBJ01_SPIKE and (chain A) and resi 330-527 and not resn NAG
sel OBJ01_SPIKE_tailsel, OBJ01_SPIKE and (chain A) and not resi 330-527 and not resn NAG

# coloring
cmd.color_deep("white", 'OBJ01', 0)
cmd.color_deep("oxygen", 'OBJ01_SPIKE_headsel', 0)
color oxygen, OBJ01_SPIKE_headsel
cmd.color_deep("palegreen", 'OBJ01_AB1', 0) #415a41
cmd.show("sticks"    ,"OBJ01_SPIKE_NAGs")
color paleyellow, OBJ01_SPIKE_NAGs
set stick_radius, 0.5, OBJ01
cmd.disable('REF')

scene scene_001, store

create OBJ01_AB1_obj, OBJ01_AB1
create OBJ01_SPIKE_obj, OBJ01_SPIKE

select OBJ01_SPIKE_headA, OBJ01_SPIKE and (chain A) and resi 330-527
select OBJ01_SPIKE_headA, OBJ01_SPIKE_headA or ((byres ((OBJ01_SPIKE_headA) extend 1)) and resn NAG)
select OBJ01_SPIKE_headA, OBJ01_SPIKE_headA or ((byres ((OBJ01_SPIKE_headA) extend 1)) and resn NAG)
create OBJ01_SPIKE_headA_obj, OBJ01_SPIKE_headA

# Selecting interactions within 4.5 Angstroms
select OBJ01_SPIKE_4A_AB1, (OBJ01_SPIKE_headA_obj) within 4.5 from OBJ01_AB1_obj
select OBJ01_AB1_4A_SPIKE, OBJ01_AB1_obj within 4.5 from (OBJ01_SPIKE_headA_obj)
select OBJ01_SPIKE_4A_AB1_byres, byres OBJ01_SPIKE_4A_AB1
select OBJ01_AB1_4A_SPIKE_byres, byres OBJ01_AB1_4A_SPIKE

# Creating CA atoms selections for visualizing interactions
create OBJ01_AB1_4A_SPIKE_byres_ca, OBJ01_AB1_4A_SPIKE_byres and name ca
create OBJ01_SPIKE_4A_AB1_byres_ca, OBJ01_SPIKE_4A_AB1_byres and name ca

# Setting visual properties for the CA atoms
set nb_spheres_size, 0.5, OBJ01_AB1_4A_SPIKE_byres_ca
set nb_spheres_size, 0.5, OBJ01_SPIKE_4A_AB1_byres_ca

cmd.disable('OBJ01_AB1_4A_SPIKE_byres_ca')
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_ca')
cmd.disable('OBJ01_SPIKE_headA_obj')
cmd.disable('OBJ01_AB1_obj')

set_view (\
    -0.344526172,    0.671150565,   -0.656398058,\
     0.923538744,    0.116845295,   -0.365269959,\
    -0.168453828,   -0.732055008,   -0.660089731,\
     0.000000000,    0.000000000, -681.960266113,\
   247.916992188,  253.305114746,  233.839996338,\
   537.662658691,  826.257873535,   20.000000000 )
scene scene_002, store

###scene_003
cmd.disable('OBJ01')
cmd.enable('OBJ01_AB1_obj',1)
cmd.enable('OBJ01_SPIKE_headA_obj',1)
scene scene_003, store;

###scene_004
copy OBJ01_PISA_SPIKE, OBJ01_SPIKE_headA_obj;
alter OBJ01_PISA_SPIKE, b=0;
hide all;
disable all; 
show surface, OBJ01_PISA_SPIKE;
enable OBJ01_PISA_SPIKE;
color white, OBJ01_PISA_SPIKE;;
alter OBJ01_PISA_SPIKE, b=0;
hide all;
disable all; 
show surface, OBJ01_PISA_SPIKE;
enable OBJ01_PISA_SPIKE;
color white, OBJ01_PISA_SPIKE;
create OBJ01_PISA_SPIKE_AB1, OBJ01_SPIKE_headA_obj or OBJ01_AB1_obj
cmd.disable('OBJ01_PISA_SPIKE_AB1')
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )
scene scene_004, store;

### modify to match your local directory 
save RBD01_output/OBJ01_Ab_PISA.pdb, OBJ01_PISA_SPIKE_AB1, 1, pdb
listselection OBJ01_SPIKE_headA, P;
listselection OBJ01_AB1, P;
system mv listselection_OBJ01* RBD01_output/.
system mv RBD01_output/listselection_OBJ01_SPIKE_headA.txt RBD01_output/listselection_OBJ01_SPIKE.txt
system cp RBD01_output/listselection*.txt ../NBIS_M_Ohlin_2411_interface_analysis_PDBdeposited/NBIS_M_Ohlin_2411_Ab321/pisarp_selections/.
###

#break -> switch to R and run arpeggio and PISA webservers on the structure

#return 
# copy the created pymol scripts to the RBD01_input folder
link or copy the Rstudio created pyscripts folder
system cp ../NBIS_M_Ohlin_2411_interface_analysis_PDBdeposited/NBIS_M_Ohlin_2411_Ab117/pyscripts .

###scene_005
# Modify OBJ01_PISA object properties and run external PyMOL script
alter OBJ01_PISA_SPIKE, b=0
run pyscripts/pisa_bsa_OBJ01_SPIKE.pml

# Apply color spectrum based on 'b' values
spectrum b, white_yellow_red, OBJ01_PISA_SPIKE, minimum=0, maximum=100

# Set transparency for certain objects
set transparency, 0.2, OBJ01_PISA_SPIKE
cmd.enable('OBJ01_SPIKE_4A_AB1_byres_ca',1)
cmd.show("nb_spheres","OBJ01_SPIKE_4A_AB1_byres_ca")
cmd.color_deep("black", 'OBJ01_SPIKE_4A_AB1_byres_ca', 0)

create OBJ01_AB1_4A_SPIKE_byres_obj, OBJ01_AB1_4A_SPIKE_byres
create OBJ01_SPIKE_4A_AB1_byres_obj, OBJ01_SPIKE_4A_AB1_byres
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_obj')
cmd.hide("cartoon"   ,"OBJ01_SPIKE_4A_AB1_byres_obj")
cmd.show("sticks","((byres (OBJ01_SPIKE_4A_AB1_byres_obj))&(sc.|(n. CA|n. N&r. PRO)))")

# Set the view for the scene
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )

# Storing the final state of the scene
cmd.hide("(OBJ01_SPIKE_4A_AB1_byres_obj and hydro)")
cmd.color_deep("black", 'OBJ01_SPIKE_4A_AB1_byres_obj', 0)

set ambient=0.5 #0.3
set direct=0.8 #0.1
set reflect=0 #0.8
set ambient_occlusion_mode, 0 #1

set ambient=0.3 #0.3
set direct=0.1 #0.1
set reflect=0.8 #0.8
set ambient_occlusion_mode, 0 #1

scene scene_005, store

###scene_005_outline
cmd.scene('''scene_005''')
select OBJ01_PISA_SPIKE_bsel, OBJ01_PISA_SPIKE and b>5
cmd.color_deep("white", 'OBJ01_PISA_SPIKE', 0)
cmd.color_deep("red", 'OBJ01_PISA_SPIKE_bsel', 0)
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_obj')
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_ca')
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
    -0.000951253,   -0.000491828, -306.120941162,\
   264.823608398,  264.255004883,  172.609924316,\
   285.501892090,  327.057495117,   20.000000000 )
scene scene_005_outline, store

###scene_006 (HA view)
copy OBJ01_PISA_AB1, OBJ01_Ab1_obj;
alter OBJ01_PISA_AB1, b=0;
hide all;
disable all; 
show surface, OBJ01_PISA_AB1;
enable OBJ01_PISA_AB1;
color white, OBJ01_PISA_AB1;;
alter OBJ01_PISA_AB1, b=0;
hide all;
disable all; 
show surface, OBJ01_PISA_AB1;
enable OBJ01_PISA_AB1;
color white, OBJ01_PISA_AB1;

alter OBJ01_PISA_AB1, b=0
run pyscripts/pisa_bsa_OBJ01_AB1.pml

# Apply color spectrum based on 'b' values
spectrum b, white_yellow_red, OBJ01_PISA_AB1, minimum=0, maximum=100
set transparency, 0.2, OBJ01_PISA_AB1
cmd.enable('OBJ01_AB1_4A_SPIKE_byres_ca',1)
cmd.show("nb_spheres","OBJ01_AB1_4A_SPIKE_byres_ca")
cmd.color_deep("black", 'OBJ01_AB1_4A_SPIKE_byres_ca', 0)

create OBJ01_AB1_4A_SPIKE_byres_obj, OBJ01_AB1_4A_SPIKE_byres
create OBJ01_AB1_4A_SPIKE_byres_obj, OBJ01_AB1_4A_SPIKE_byres
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_obj')
cmd.hide("cartoon"   ,"OBJ01_AB1_4A_SPIKE_byres_obj")
cmd.show("sticks","((byres (OBJ01_AB1_4A_SPIKE_byres_obj))&(sc.|(n. CA|n. N&r. PRO)))")
cmd.enable('OBJ01_AB1_4A_SPIKE_byres_obj',1)
cmd.color_deep("black", 'OBJ01_AB1_4A_SPIKE_byres_obj', 0)
scene scene_006, store

set_view (\
     0.550908923,    0.556760132,    0.621705890,\
    -0.803075075,    0.556353986,    0.213393703,\
    -0.227079347,   -0.616838217,    0.753621638,\
     0.000912093,    0.000299523, -171.871154785,\
   257.569885254,  278.115051270,  166.190826416,\
   147.119155884,  196.665847778,   20.000000000 )
cmd.hide("(OBJ01_AB1_4A_SPIKE_byres_obj and hydro)")
scene scene_006, store


#####
###scene_007
run ../pymol_scripts/findseq.py
cmd.scene('''scene_002''')
create OBJ01_PRINT_AB1, OBJ01_PISA_AB1
cmd.color_deep("palegreen", 'OBJ01_PRINT_AB1', 0)
set_view (\
     0.550908923,    0.556760132,    0.621705890,\
    -0.803075075,    0.556353986,    0.213393703,\
    -0.227079347,   -0.616838217,    0.753621638,\
     0.000912093,    0.000299523, -171.871154785,\
   257.569885254,  278.115051270,  166.190826416,\
   147.119155884,  196.665847778,   20.000000000 )
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_obj')
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_ca')
scene scene_007, store

# for Abs
findseq GFTFSYSG, OBJ01_PRINT_AB1 and chain H, OBJ01_HC-CDR1;
findseq IYGGSGST, OBJ01_PRINT_AB1 and chain H, OBJ01_HC-CDR2;
findseq ARDYSYLDY, OBJ01_PRINT_AB1 and chain H, OBJ01_HC-CDR3;
cmd.color_deep("paleyellow", 'OBJ01_HC-CDR1', 0);
cmd.color_deep("lightorange", 'OBJ01_HC-CDR2', 0);
cmd.color_deep("lightpink", 'OBJ01_HC-CDR3', 0);
findseq QSISSY, OBJ01_PRINT_AB1 and chain L, OBJ01_LC-CDR1;
findseq YAASS, OBJ01_PRINT_AB1 and chain L, OBJ01_LC-CDR2; ### IMPORTANT: deselect to keep only AAS
findseq QQYYDLYT, OBJ01_PRINT_AB1 and chain L, OBJ01_LC-CDR3;
cmd.color_deep("paleyellow", 'OBJ01_LC-CDR1', 0);
cmd.color_deep("lightorange", 'OBJ01_LC-CDR2', 0);
cmd.color_deep("lightpink", 'OBJ01_LC-CDR3', 0);
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_ca')
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_ca')
cmd.enable('OBJ01_SPIKE_4A_AB1_byres_ca',1)
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_ca')
cmd.disable('OBJ01_SPIKE_obj')
#for ambient settings
set ambient=0.5
set direct=0.8
set reflect=0
set ambient_occlusion_mode, 0

#default settings:
set ambient=0.3
set direct=0.1
set reflect=0.8
set ambient_occlusion_mode, 1
cmd.disable('OBJ01')

scene scene_007, store

###scene_008
cmd.scene('''scene_005''')
create OBJ01_PRINT_SPIKE, OBJ01_PISA_SPIKE
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )
cmd.disable('OBJ01_PISA_SPIKE')
ramp_new ramp_PRINT_AB1, OBJ01_PRINT_AB1, [0,5], [atomic,atomic];
color white, OBJ01_PRINT_SPIKE
color ramp_PRINT_AB1, OBJ01_PRINT_SPIKE
set transparency, 0.2, OBJ01_PRINT_SPIKE
scene scene_008, store 

### scene_008_PRINT
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
    -0.000979975,   -0.000482099, -192.937225342,\
   258.575683594,  263.023162842,  177.854690552,\
   172.347778320,  213.903442383,   20.000000000 )
set ambient=0.5; set direct=0.8; set reflect=0; set ambient_occlusion_mode, 0
set transparency, 0, OBJ01_PRINT_SPIKE #0.2
cmd.set('depth_cue',1,'',0)
set cartoon_tube_radius, 0.5, OBJ01_AB1_lines,

scene scene_008_PRINT, store

### scene_008_angle
select HCDR2del, OBJ01_AB1_obj and chain H and resi 39 and name ca
select LCDR2del, OBJ01_AB1_obj and chain L and resi 39 and name ca
select RBD_F486_CA, OBJ01_SPIKE_obj and chain A and resi 486 and name ca
angle Ab_RBD_angle, RBD_F486_CA, HCDR2del, LCDR2del

select HCDR1del, OBJ01_AB1_obj and chain H and resi 34 and name ca
select LCDR1del, OBJ01_AB1_obj and chain L and resi 33 and name ca

angle Ab_RBD_angle_02, RBD_F486_CA, HCDR1del, LCDR1del

cmd.color_deep("black", 'Ab_RBD_angle', 0)
cmd.color_deep("black", 'Ab_RBD_angle_02', 0)
set dash_width, 5, Ab_RBD_angle,
set dash_width, 5, Ab_RBD_angle_02,
cmd.disable('OBJ01_AB1_lines')
set_view (\
    -0.554955840,    0.560087562,   -0.615080893,\
     0.787983596,    0.590925753,   -0.172867715,\
     0.266646564,   -0.580609918,   -0.769279778,\
    -0.000979975,   -0.000482099, -192.937225342,\
   258.575683594,  263.023162842,  177.854690552,\
   172.347778320,  213.903442383,   20.000000000 )
cmd.hide("labels"    ,"Ab_RBD_angle")
scene scene_008_angle, store


####scene_009 (if not Ab)
cmd.scene('''scene_008''')
cmd.disable('ramp_PRINT_AB1')
cmd.enable('OBJ01_AB1_obj',1)
cmd.color_deep("black", 'OBJ01_AB1_obj', 0)
create OBJ01_AB1_lines, OBJ01_AB1_obj
cartoon tube, OBJ01_AB1_lines
set cartoon_tube_radius, 0.2, OBJ01_AB1_lines, 
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )

select OBJ01_ACE_bound, OBJ01_PISA_SPIKE and b > 0 
listselection OBJ01_ACE_bound, P;
system mv listselection_OBJ01_ACE_bound* RBD01_output/pisarp_focus
scene scene_009, store

###scene_010 (if Ab)
create OBJ01_AB1_lines, OBJ01_HC* or OBJ01_LC*
cmd.color_deep("black", 'OBJ01_AB1_lines', 0)
cmd.hide("surface"   ,"OBJ01_AB1_lines")
cmd.show("cartoon"   ,"OBJ01_AB1_lines")
cartoon tube, OBJ01_AB1_lines

run ../pymol_scripts/listselection.py

listselection OBJ01_HC-CDR1, P;
listselection OBJ01_HC-CDR2, P;
listselection OBJ01_HC-CDR3, P;
listselection OBJ01_LC-CDR1, P;
listselection OBJ01_LC-CDR2, P;
listselection OBJ01_LC-CDR3, P;
system mv listselection_OBJ01_*-CDR* RBD01_output/pisarp_focus
!!! TO ADD !!!
set_view (\
    -0.554955840,    0.560087562,   -0.615080893,\
     0.787983596,    0.590925753,   -0.172867715,\
     0.266646564,   -0.580609918,   -0.769279778,\
    -0.000979975,   -0.000482099, -192.937225342,\
   258.575683594,  263.023162842,  177.854690552,\
   172.347778320,  213.903442383,   20.000000000 )

scene scene_010, store

### copy RBD01_output/pisarp_focus groups
system cp RBD01_output/pisarp_focus/listselection*.txt ../NBIS_M_Ohlin_2411_interface_analysis_PDBdeposited/NBIS_M_Ohlin_2411_Ab117/pisarp_focus/.

### run arpeggio and R analysis


###scene_011 (select Ab_binding residues)
cmd.scene('''scene_005''')
cmd.disable('OBJ01_PISA_SPIKE')
util.cnc("OBJ01_SPIKE_4A_AB1_byres_obj",_self=cmd)
cmd.enable('OBJ01_AB1_4A_SPIKE_byres_obj',1)
util.cba(144,"OBJ01_AB1_4A_SPIKE_byres_obj",_self=cmd)
create OBJ01_ARP, OBJ01_SPIKE_4A_AB1_byres_obj or OBJ01_AB1_4A_SPIKE_byres_obj
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_ca')
cmd.disable('OBJ01_SPIKE_4A_AB1_byres_obj')
cmd.disable('OBJ01_AB1_4A_SPIKE_byres_obj')
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )
run pyscripts/OBJ01_AB1.pml
group OBJ01_AB1_hphobic, OBJ01_AB1_hphobic*;
group OBJ01_AB1_hbond, OBJ01_AB1_hbond*;
color red, OBJ01_AB1_hbond;
set dash_gap, 0, *hbond;
set dash_radius, 0.4, *hbond;
set dash_transparency, 0.4, *hbond;
set dash_radius, 0.25, *hphobic;
hide labels;
select OBJ01_ARP_SPIKE_4A_AB1, byres (((OBJ01_ARP) within 4.5 from OBJ01_AB1_obj) and not (chain H or chain L)) 
util.cba(144,"OBJ01_ARP_SPIKE_4A_AB1",_self=cmd)
select OBJ01_ARP_AB1_4A_SPIKE, byres ((OBJ01_ARP within 4.5 from OBJ01_SPIKE_headA_obj) and (chain H or chain L))
util.color_deep("black", 'OBJ01_ARP_AB1_4A_SPIKE', 0)
util.cnc("OBJ01_ARP_AB1_4A_SPIKE",_self=cmd)


scene scene_011, store

###scene_012 tune
run pyscripts/OBJ01_AB1_tune.pml
cmd.hide("everything","OBJ01_ARP")
#manual modifications to add contacted bb
cmd.hide("((byres (OBJ01_ARP))&(bb.&!(n. CA|n. N&r. PRO)))")
cmd.show("lines"     ,"OBJ01_ARP_show_bb")
cmd.hide("(OBJ01_ARP_show_bb and hydro)")
cmd.disable('OBJ01_ARP_show_bb')

set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )
scene scene_012, store

cene scene_011, store
cmd.scene('''scene_011''')
cmd.hide("sticks"    ,"OBJ01_ARP")
cmd.show("sticks"    ,"OBJ01_ARP_show")
cmd.hide("(OBJ01_ARP_show and hydro)")
scene scene_012, store

cmd.hide("((byres (OBJ01_ARP_show))&(bb.&!(n. CA|n. N&r. PRO)))")
cmd.show("lines"     ,"OBJ01_ARP_show")
# manual select contacted bb residues
cmd.hide("lines"     ,"OBJ01_ARP")
cmd.show("lines"     ,"arptuned_show")
cmd.hide("(arptuned_show and hydro)")
set_view (\
    -0.552252352,    0.561351240,   -0.616360784,\
     0.789640784,    0.589314520,   -0.170793146,\
     0.267355949,   -0.581026852,   -0.768718481,\
     0.000000000,    0.000000000, -161.489837646,\
   264.985382080,  274.591156006,  170.390014648,\
   140.712036133,  182.267700195,   20.000000000 )
cmd.disable('arptuned_show')
scene scene_012, store

### scene_012_escape
cmd.scene('''scene_012''')
create OBJ01_ARP_escape, (OBJ01 and chain A and (resi 484 or resi 501)) and not (name n or name c or name O or elem H)
cmd.show("sticks"    ,"OBJ01_ARP_escape")
cmd.show("sticks"    ,"OBJ01_ARP_escape")
cmd.color_deep("white", 'OBJ01_ARP_escape', 0)
util.cnc("OBJ01_ARP_escape",_self=cmd)
set_view (\
    -0.554955840,    0.560087562,   -0.615080893,\
     0.787983596,    0.590925753,   -0.172867715,\
     0.266646564,   -0.580609918,   -0.769279778,\
    -0.000979975,   -0.000482099, -192.937225342,\
   258.575683594,  263.023162842,  177.854690552,\
   172.347778320,  213.903442383,   20.000000000 )
scene scene_012_escape, store

