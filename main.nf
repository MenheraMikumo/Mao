params.rawdata = "rawdata"

Channel
    .fromFilePairs("${params.rawdata}/*_{1,2}.fq.gz")
    .set {toFilter}

process Filter {

    container "911094685195.dkr.ecr.ap-northeast-1.amazonaws.com/test"
    publishDir "results"
    input:
        set val(smp),file(reads) from toFilter

    output:
        file("${smp}.fastp.json")

    script:
        """
        fastp -q 20 -u 20 -n 5 -i ${reads[0]} -I ${reads[1]} -j ${smp}.fastp.json -w 8 -o ${smp}_clean_1.fq.gz -O ${smp}_clean_2.fq.gz
        """
}
