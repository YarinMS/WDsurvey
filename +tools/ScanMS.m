function [Results] = ScanMS(list,Args)
% Create a list for MS . look for coordinates [ra,dec]
% report the least overlapping frame. document contamiantions and near edge
% frames
arguments
    list 
    Args.CropID ={}; 
    Args.Coords
end
  Overlap =[];
         for Iid = 1:24
            MS  = MatchedSources.readList(list(Iid));

            Ind = MS.coneSearch(Args.Coords(1),Args.Coords(2),6); % 6 arcsec search radius to flag contaminatiors

            if ~isempty(Ind.Ind)
                if Ind.Nsrc >1
                    fprintf('\n Source is probably contaminated')
                    Results.Contaminated = 1;
                    Res = getFlags1(MS,'SrcIdx',Ind.Ind(1));
                else
                    Res = getFlags1(MS,'SrcIdx',Ind.Ind);
                end
                Results.Flags = Res;

                if Res.EFcounts > 0 || ~isempty(Overlap)
                    fprintf('\n Source has %i overlapping data points\nIn CropID %i\n',Res.EFcounts,Iid)
                    if Res.EFcounts ==0
                        Overlap = [Overlap;0];
                        Args.CropID{end +1} = Iid;
                    else
                        Overlap = [Overlap;Res.EFcounts];
                        Args.CropID{end +1} = Iid;
                    end
                end
                if Res.BFcounts(1,end) > 1
                    Results.NearEdge = 1;
                end

                if isempty(Overlap)
                    fprintf('\n Source found in CropID %i',Iid)
                    Args.CropID    = Iid;
                    Results.Ind    = Ind;
                    Results.CropID = Iid;
                    break
                elseif Iid == 24 || Overlap(end)==0
                    
                       fprintf('\n Source found in CropID %i', Args.CropID{:})
                       [m,id] = min(Overlap);
                       Args.CropID = Args.CropID{id};
                       fprintf('\n Source CropID with minimal overlap %i (%i overlapping points)\n', Args.CropID,m)
                       Args.CropID    = Iid;
                       Results.Ind    = Ind;
                       Results.CropID = Iid;
                        break

                
                end
            elseif Iid == 24 && ~isempty(Overlap)
                    fprintf('\n Source found in CropID %i', Args.CropID{:})
                       [m,id] = min(Overlap);
                       Args.CropID = Args.CropID{id};
                       fprintf('\n Source CropID with minimal overlap %i (%i overlapping points)\n', Args.CropID,m)
                       Args.CropID    = Iid;
                       Results.Ind    = Ind;
                       Results.CropID = Iid;
                       break

            elseif Iid == 24 && isempty(Overlap) 
                fprintf('\n Source Could not be found in visit %s\n',list(Iid).Folder{end}(end-7:end))
                Results = [];
            end

         end
end