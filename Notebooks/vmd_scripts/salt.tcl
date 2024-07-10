# Set the parent directory
set parent_directory "C:/Users/sptrp/OneDrive/Documents/Reegina/mine/pri"

# Get list of protein folders
set protein_folders [glob -directory $parent_directory -type d *]

# Loop through each protein folder
foreach protein_folder $protein_folders {
    set protein_name [file tail $protein_folder]

    # Find PDB file, assuming the pattern for PDB file names
    set pdb_files [glob -directory $protein_folder -nocomplain protein.hmass.parm7]
    if {[llength $pdb_files] == 0} {
        puts "PDB file not found for $protein_name"
        continue
    }

    # Find trajectory file, assuming the pattern for trajectory file names
    set traj_files [glob -directory $protein_folder -nocomplain eq1.crd]
    if {[llength $traj_files] == 0} {
        puts "Trajectory file not found for $protein_name"
        continue
    }

    # Load the PDB file
    mol new [lindex $pdb_files 0] waitfor all

    # Load the trajectory file
    mol addfile [lindex $traj_files 0] type crd waitfor all
    
    # Wrap the trajectory to avoid RMSD calculation errors
    # Set the simulation box using the center of mass of all atoms
  

    ## Align to first frame

    # The frame being compared
    set reference [atomselect top "protein and backbone" frame 0]
    
    # The frame to be compared
    set compare [atomselect top "protein and backbone"]

    # Get the number of frames of the trajectory 
    set num_steps [molinfo top get numframes]

    # Get the correct num as the trajectory start from zero
    set outfile [open "$protein_folder/rmsd.dat" w]

    for {set frame 0} {$frame < $num_steps} {incr frame} {
        # Get the correct frame
        $compare frame $frame
        
        # Compute the 4*4 matrix transformation that takes one set of coordinates onto the other 
        set trans_mat [measure fit $compare $reference]
        
        # Do the alignment
        $compare move $trans_mat
        
        # Compute the RMSD
        set rmsd [measure rmsd $compare $reference]
        
        # Print the RMSD
        puts $outfile "$frame    $rmsd"
    }
    close $outfile

    # RMSF calculation
    set num [expr {$num_steps - 1}]
    set outfile [open "$protein_folder/rmsf.dat" w]
    set sel [atomselect top "protein and name CA"]
    set rmsf [measure rmsf $sel first 0 last $num step 1]
    for {set i 0} {$i < [$sel num]} {incr i} {
        puts $outfile "[expr {$i+1}] [lindex $rmsf $i]"
    } 
    close $outfile

    # Clean up selections and molecules if necessary
    [atomselect top "all"] delete
    mol delete top
}

# Close VMD session if running as a script
exit
