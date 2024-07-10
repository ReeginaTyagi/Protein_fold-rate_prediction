# Set the parent directory
set parent_directory "C:/Users/sptrp/OneDrive/Documents/Reegina/mine/pri"

# Get list of protein folders
set protein_folders [glob -directory $parent_directory *]

# Loop through each protein folder
foreach protein_folder $protein_folders {
    set protein_name [file tail $protein_folder]

    # Create a salt bridges directory inside the current protein folder
    set saltbridge_dir "$protein_folder/saltbridges"
    if {![file exists $saltbridge_dir]} {
        file mkdir $saltbridge_dir
    }

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

    # Load the salt bridge analysis package and run the analysis
    package require saltbr
    saltbr -sel [atomselect top "protein"] -log $saltbridge_dir/saltbridges.log -outdir $saltbridge_dir

    # Optional: Clean up selections and molecules if necessary
    # [atomselect top "all"] delete
    # mol delete top
}

# Optional: Close VMD session if running as a script
exit
