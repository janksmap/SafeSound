import subprocess
from tqdm import tqdm

container_name = "lowerquality-gentle"
image_name = "lowerquality/gentle"

def start():
        container_status = check_if_container_exists(container_name)
        if container_status == False:
            create_container()
            tqdm.write("Container does not exist. Creating container now...")
        else:
            start_container()
            tqdm.write("Starting gentle docker container...")

def start_container():
     cmd = f"docker start > /dev/null {container_name}" # "> /dev/null" sends the output into the dark abyss (gets rid it)
     run_command_async(cmd)

def create_container():
     cmd = f"docker run -p 8765:8765 --name {container_name} {image_name}"
     run_command_async(cmd)

def check_if_container_exists(container_name):
    try:
        result = subprocess.run(
            ["docker", "ps", "-a", "--filter", f"name={container_name}", "--format", "{{.Names}}"],
            capture_output=True, text=True, check=True
        )
        return container_name in result.stdout.strip().split("\n") # Should I just return true? Does the name need to be returned?
    except subprocess.CalledProcessError:
           return False

      
def stop_docker(container_name):
    cmd = f"docker stop {container_name}"
    run_command(cmd)

def run_command_async(cmd):
    subprocess.Popen(cmd, shell=True, text=True)

def run_command(cmd):
    return subprocess.run(cmd, capture_output=True, shell=True, text=True)

