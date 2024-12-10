% ID : Get forced photometry for marvin (catalogs) data [ main worksapce] 
%
% MarvinFP/
% │
% ├── Marvin/
% │   ├── catalogs/                # Light curve data and transit events
% │   ├── flagged_events/          # Light currves with flagged events
% │
% ├── Scripts/
% │   ├── readPngInfo.m            # Get event info.
% │   ├── locate_fits.m            # Locate and filter FITS files
% │   ├── copy_unpack_fits.m       # Copy and unpack FITS files
% │   ├── activate_pipeline.m      # Activate pipeline on the filtered images
% │   ├── forced_photometry.m      # Perform forced photometry
% │   ├── cleanup_origin.m         # Clean up temporary files on origin
% │
% ├── Products/
% │   ├── pipeline_results/        # Results after pipeline execution
% │   ├── photometry_results/      # Forced photometry results
% │
% ├── Logs/                        # Logs for debugging
% │   ├── process.log              # Workflow progress log
% │
% ├── Config/
% │   ├── paths_config.m           # Centralized path management
% │
% └── README.md                    # Documentation for workflow


%% Draft workspace
imgsDir = '~/Projects/NightRunRes/';
Res = marvinFP.readPngInfo(imgsDir)














%% Main workspace




%% ####### Functions
