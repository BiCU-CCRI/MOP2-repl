# MOP2-repl

MOP2-repl is a versatile pipeline that encapsulates the Master of Pores 2 (MOP2) pipeline created by Luca Cozzute, as described in their paper [here](https://link.springer.com/protocol/10.1007/978-1-0716-2962-8_13). This pipeline employs a slightly modified version of the original MOP2 pipeline.

## Usage

MOP2-repl breaks down the MOP2 pipeline into three modular steps, each of which can be found under the `modules/` directory. Users can customize various parameters by editing the `params.config` file. The `samples` parameter in the configuration file should point to a JSON file containing the paths of samples and their respective replicates. It is essential to maintain the source structure as follows:

datadirectory/
Sample1_replicate1/
*.fast5
Sample2_replicate2/
*.fast5

## Resources

MOP2-repl relies on [Nextflow](https://www.nextflow.io/) for execution. To ensure a smooth setup, we recommend creating a Conda environment with the dependencies used for testing. You can do this by running the following command:

```bash
conda env create -f mop2.yml
```
To execute the pipeline, simply run the following command:
```bash
nextflow run MOP2-repl
```
By appending -resume previous executions can be resumed and only new samples will be run. Please refer to the Nextflow documentation for more information on executing Nextflow pipelines.
