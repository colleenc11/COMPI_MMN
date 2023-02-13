function [ fileMips ] = compute_mips( fileMap )
% Compute Maximum intensity projection of nifti in X/Y/Z and replicate the slice
% over whole volume to keep image dimensions
%
% IN
%   fileMap     nifti file
% OUT
%   fileMips    mipX_* mipY_* mipZ_* nifti files of projections in x/y/z,
%               preserving map size by replication of mip slice over whole
%               projection dimension

V = spm_vol(fileMap);
Y = spm_read_vols(V);

pfxArray = {'mipX_','mipY_','mipZ_'}; 
for d = 1:3
    V.fname = spm_file(fileMap, 'prefix', pfxArray{d});
    nVoxelDim = ones(1,3);
    nVoxelDim(d) = size(Y,d); % only mip dimension will be replicated
    mipY = repmat(max(Y, [], d), nVoxelDim); % replicate mip slice over projection dimension
    spm_write_vol(V, mipY);
    
    fileMips{d} = V.fname;
end
end

