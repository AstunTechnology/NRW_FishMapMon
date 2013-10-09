import shlex
import subprocess
from rq import get_current_job


def export_image(url):

    job = get_current_job()

    try:
        job_key = job.key.replace('rq:job:', '')
    except AttributeError:
        job_key = 'test'

    args = 'casperjs ../scripts/export_map.js %s %s' % (job_key, url)
    args = shlex.split(args)

    try:
        result = subprocess.check_output(args)
    except subprocess.CalledProcessError:
        # Re-raise the exception so that details will be logged by RQ in Redis
        raise

    return result
