function matlabbatch = compi_getjob_imcalc_source(scans, fileName, outputdir)
%-----------------------------------------------------------------------
% Job saved on 11-Sep-2023 14:23:52 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

matlabbatch{1}.spm.util.imcalc.input = scans;
matlabbatch{1}.spm.util.imcalc.output = fileName;
matlabbatch{1}.spm.util.imcalc.outdir = {outputdir};
matlabbatch{1}.spm.util.imcalc.expression = ['(i1+i2+i3+i4+i5+i6+i7+i8+i9+i10' ...
                                             '+i11+i12+i13+i14+i15+i16+i17+i18+i19+i20' ...
                                             '+i21+i22+i23+i24+i25+i26+i27+i28+i29+i30' ...
                                             '+i31+i32+i33+i34+i35+i36+i37+i38+i39+i40' ...
                                             '+i41+i42+i43)/43'];
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
