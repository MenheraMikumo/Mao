params.rawdata = "rawdata"
params.outPath = "results"
params.reference = "s3://mikumo-test/reference/reference.fa"

Channel
    .fromFilePairs("${params.rawdata}/*_{1,2}.fq.gz")
    .into {toClean;toFilter}

reference = file(params.reference)

process Filter {

    cpus 1
    memory '2 GB'
    publishDir "${params.outPath}/00.QC", mode:'copy', pattern:"*.json"

    input:
        set val(smp),file(reads) from toFilter

    output:
        file("${smp}.fastp.json")
        file("${smp}.fastp.html")
        set val(smp),file("${smp}_clean_*.fq.gz") into toAlign

    script:
        """
        fastp -q 20 -u 20 -n 5 -i ${reads[0]} -I ${reads[1]} -j ${smp}.fastp.json -w 8 -o ${smp}_clean_1.fq.gz -O ${smp}_clean_2.fq.gz
        mv fastp.html ${smp}.fastp.html
        """
}
process Fastqc {

    cpus 1
    memory '2 GB'
    publishDir "${params.outPath}/00.QC",mode:'copy'

    input:
        set val(smp),file(reads) from toClean

    output:
        file("*.zip")
        file("*.html")

    script:
        """
        fastqc ${reads[0]}
        fastqc ${reads[1]}
        """
}

process Alignment {

    cpus 1
    memory '2 GB'
    publishDir "${params.outPath}/01.Alignment",mode:'copy'

    input:
        set val(smp),file(reads) from toAlign
        file fasta from reference

    output:
        file "${smp}.cram"
        file "${smp}.stats"

    script:
        """
        minimap2 -t 8 -R '@RG\tID:${smp}\tSM:${smp}\tPL:ILLUMINA' -ax sr $fasta - | \
        sambamba view -t 8 -f bam -S /dev/stdin -o ${smp}.bam
        sambamba sort --tmpdir=TMP -t 8 ${smp}.bam -o ${smp}.sort.bam
        sambamba markdup --tmpdir=TMP -t 8 ${smp}.sort.bam ${smp}.mkdup.bam
        sambamba flagstat ${smp}.mkdup.bam > ${smp}.stats
        sambamba view -h -f cram -T $fasta -o ${smp}.cram ${smp}.mkdup.bam
        """
}
