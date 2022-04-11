# Testing with a branch

## Using a remote branch

If you need to run the tests against a branch of an application other than
deployed-to-production you need to explicitly build it as below:

```bash
$ make -j4 clone pull PUBLISHER_COMMITISH=your_branch
$ docker-compose build publisher
$ make start test-publisher stop
```

When making changes to an application you will need to rebuild the image before
the new version will be used.

```bash
$ docker-compose build publisher
```

When you have finished testing against your branch version and want to switch back
to the deployed-to-production version you will need to untag the built image before
you can re-pull.  The `clean_docker` make recipe will untag all locally built images.

```bash
$ make clean_docker
$ make pull
```

## Using a local branch

If you want to use a local version of an application, symlink your
directory into `./apps`. For example:

```
rm -rf apps/publishing-api
ln -s path/to/publishing-api apps/publishing-api
```
