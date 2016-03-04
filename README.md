logreplay-docker
============

See also [logreplay](https://github.com/hellofresh/logreplay) repo.

#### Build:

        $ git clone git@github.com:hellofresh/logreplay-docker.git
        $ docker build -t my/logreplay .

#### Usage:

The container can be run in two different modes:  
  - _mount-only mode_: Only mounting the provided S3 bucket inside the container and start a new shell to explore the stored data in a Unix environment. Do not send any logs to an ElasticSearch (ES) cluster.
    - use `replay --mount-only` as container startup commands.    
  - _replay mode_: mount the S3 bucket inside the container **and** send logs contained in the S3 bucket to an ES cluster.
    - use `replay` as the only container startup command.

**Only mount an S3 bucket and start a shell to explore the data:**

        docker run \
          -it \
          --privileged \
          --rm \
          -e "AWS_ACCESS_KEY_ID=..." \
          -e "AWS_SECRET_ACCESS_KEY=..." \
          -e "S3_BUCKET=<S3 bucket to mount>" \
          --name logreplay \
          my/logreplay replay --mount-only
          
*Note:* The contents of the mounted S3 bucket will then be accessible under `/mnt/s3`

**Re-play logs to ES:**

        docker run \
          -t \
          -a STDOUT \
          -a STDERR \
          --privileged \
          --rm \
          -e "AWS_ACCESS_KEY_ID=..." \
          -e "AWS_SECRET_ACCESS_KEY=..." \
          -e "S3_BUCKET=<S3 bucket to mount>" \
          -e "LOGS_PATH=<path to logs in question, starting from the sub-directory of the root bucket>" \
          -e "ES_TYPE=<type field as part of Filebeat configuration>" \
          -e "ES_HOST=http://<ElasticSearch host>:<ElasticSearch port>" \
          -e "ES_INDEX=<basename of the ElasticSearch index to use>" \
          --name logreplay \
          my/logreplay replay

