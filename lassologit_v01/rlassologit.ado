*! rlassologit 
*! part of the lassologit package (v0.1)
*! last edited: 6may2019
*! authors: aa/ms

cap program drop rlassologit
program rlassologit, eclass sortpreserve

	version 13
	
	syntax [anything] [if] [in]  [, * ]
						
	lassologit `anything', rigorous `options'
						
end
