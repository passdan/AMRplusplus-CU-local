// Load modules
include { index ; bwa_align } from '../modules/Alignment/bwa'

// resistome
include { runresistome ; runsnp ; resistomeresults ; runrarefaction ; build_dependencies} from '../modules/Resistome/resistome'


workflow FASTQ_RESISTOME_WF {
    take: 
        read_pairs_ch
        amr
        annotation

    main:
        // download resistome and rarefactionanalyzer
        if (file("${baseDir}/bin/resistome").isEmpty()){
            build_dependencies()
        }
        // Index
        index(amr)
        // AMR alignment
        bwa_align(amr, index.out, read_pairs_ch )
        runresistome(bwa_align.out.bwa_sam,amr, annotation )
        runsnp(bwa_align.out.bwa_sam )
        resistomeresults(runresistome.out.resistome_counts.collect())
        runrarefaction(bwa_align.out.bwa_sam, annotation, amr)
    emit:
        rarefaction_results = runrarefaction.out.rarefaction


}
