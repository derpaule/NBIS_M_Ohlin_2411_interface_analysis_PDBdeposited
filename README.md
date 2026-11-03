# Custom visualization of Ab/antigen interactions by tidying PISA and Arpeggio outputs in R and PyMol

The auxiliary scripts [NBIS_M_Ohlin_2411_Ab321](NBIS_M_Ohlin_2411_Ab321/NBIS_M_Ohlin_2411_Ab321.html) and [NBIS_M_Ohlin_2411_Ab117](NBIS_M_Ohlin_2411_Ab117/NBIS_M_Ohlin_2411_Ab117.html) were used to analyze the Ab321/RBD and Ab117/RBD interfaces, as presented in our [publication](), and also compared to the ACE2/RBD interface. 

The scripts are work in progress, but provide a framework to analyze and visualize antigen/antibody interactions. 
If you know R and PyMol you could extend this script to other outputs, also consider AI tools. Or you could also transform this into a more automated solution. [Examples](https://pymolwiki.org/Jupyter) exist for PyMol embedded code/analysis within Jupyter notebooks. 

Check the pml files (ASCII text), and copy commands scene-by-scene to move forward in PyMol. 
A break indicates when it´s time to create output from PISA or Arpeggio webservers. 
These outputs are imported to create summary boxplot visualizations of interaction surfaces, as well as additional PyMOl scripts used in the main PyMOL session scripts.

The [listselection](https://pymolwiki.org/ListSelection2) and [findseq](https://pymolwiki.org/Findseq) scripts are required for analysis.

The PyMOL commands `OBJ01.pml` can be found in the `PyMOL_session` folder. 
The PDB `OBJ01_Ab321_aligned.pdb` corresponds to the deposited [PDB: 9TK0](https://www.rcsb.org/structure/9TK0), but is aligned with the Ab117/RBD interface for visualization purposes. 
The PDB `OBJ00_ACE2_aligned.pdb` corresponds to the deposited [PDB: 7A94](https://www.rcsb.org/structure/7A94) displaying the RBD/ACE2 complex.

The scripts have been tested with these deposited PDB files of the two Abs:

-   [Ab117 with PDB code 9IB1](https://www.rcsb.org/structure/9IB1)
-   [Ab321 with PDB code 9TK0](https://www.rcsb.org/structure/9TK0); Note: not released yet.
-   [ACE2 with PDB code 7A94](https://www.rcsb.org/structure/7A94)

The branch `NBIS_M_Ohlin_2411_interface_analysis_vscoded_mimotopes` contains additional analyses of Ab/Spike complexes identified using [Foldseek-multimer](https://github.com/steineggerlab/foldseek). 

More information about running the analysis is given in the index file.  

Please raise issues if you find errors, need help, or would like to have this developed into a more automated solution.

