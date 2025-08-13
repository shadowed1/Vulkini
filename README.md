# Vulkini
An installer enabling the Venus Vulkan driver in Crostini for a large performance boost

Installer is not made yet. Please be careful. To install manually:

1. Back up your VM or don't
2. Go to Chrome://flags and enable GPU enabled
3. Start Crostini/Penguin

# =#=#=#= <br>
# x86_64: <br>
# =#=#=#= <br>


`sudo apt install nano ` <br>
`sudo nano /etc/apt/sources.list` <br>

`deb-src [arch=amd64,i386] http://deb.debian.org/debian sid main` <br>
`deb http://http.us.debian.org/debian sid main non-free contrib` <br>

`sudo apt update` <br>
`sudo apt install -y vulkan-tools` <br>
`sudo apt install -y libepoxy-dev` <br>
`sudo apt install -y libvulkan-dev` <br>
`sudo apt install -y python3-yaml` <br>
`sudo apt install -y git` <br>
`sudo apt install -y meson` <br>
`sudo apt install -y pkg-config` <br>
`sudo apt install -y pkg-config libvulkan-dev` <br>
`sudo apt install -y clang libclang-dev` <br>
`sudo apt install -y zstd tar` <br>
`sudo apt install -y mesa-utils` <br>
`sudo apt install -y cmake` <br>
`sudo apt install -y pkg-config cmake` <br>
`sudo apt install -y lua5.4` <br>
`sudo apt install -y liblua5.4-dev` <br>
`sudo apt install -y vulkan-validationlayers` <br>
`sudo apt install -y libunwind-dev` <br>
`sudo apt install -y hwdata` <br>
`sudo apt install -y llvm` <br>
`sudo apt install -y llvm-dev` <br>
`sudo apt install -y clang` <br>
`sudo apt install -y libdisplay-info-dev` <br>

`cd ~` <br>
`mkdir venus` <br>
`cd venus` <br>
`git clone https://gitlab.freedesktop.org/mesa/mesa.git` <br>
`sudo apt-get build-dep mesa -y` <br>
`cd ~/venus/mesa` <br>
`git pull origin` <br>
<br>
`meson setup --reconfigure build64 \` <br>
 ` --libdir /usr/lib/x86_64-linux-gnu \` <br>
  `--wrap-mode=nofallback \` <br>
  `-Dllvm=enabled \` <br>
  `-Dprefix=/usr \` <br>
  `-Dgallium-drivers=virgl,zink \` <br>
  `-Dvulkan-drivers=virtio \` <br>
  `-Dvulkan-layers=device-select \` <br>
  `-Dglx=dri \` <br>
  `-Degl=enabled \` <br>
  `-Dgbm=enabled \` <br>
  `-Dgallium-vdpau=disabled \` <br>
  `-Dvalgrind=disabled` <br>
<br>
  `sudo ninja -C build64 install` <br>
<br>
`mkdir -p ~/.local/share/meson/cross` <br>
`sudo nano ~/.local/share/meson/cross/gcc-i686` <br>
<br>
`# gcc-i686` <br>
`[binaries]` <br>
`c = '/usr/bin/gcc'` <br>
`cpp = '/usr/bin/g++'` <br>
`ar = '/usr/bin/gcc-ar'` <br>
`strip = '/usr/bin/strip'` <br>
`pkg-config = '/usr/bin/i686-linux-gnu-pkg-config'` <br>
`llvm-config = '/usr/bin/llvm-config'` <br>
`cmake = '/usr/bin/cmake'` <br> 
<br>
`[built-in options]` <br>
`c_args = ['-m32']` <br>
`c_link_args = ['-m32']` <br>
`cpp_args = ['-m32']` <br>
`cpp_link_args = ['-m32']` <br>
<br>
`[host_machine]` <br>
`system = 'linux'` <br>
`cpu_family = 'x86'` <br>
`cpu = 'i686'` <br>
`endian = 'little'` <br>
<br>
`sudo apt install -y gcc-multilib` <br>
`sudo apt install -y g++-multilib` <br>
`sudo dpkg --add-architecture i386` <br>
`sudo apt-get update -y` <br>
`sudo apt install -y pkg-config:i386` <br>
`sudo apt-get -t sid install -y libdrm-dev:i386` <br>
`sudo apt install -y libwayland-dev:i386` <br>
`sudo apt install -y libwayland-egl-backend-dev:i386` <br>
`sudo apt install -y libxext-dev:i386` <br>
`sudo apt install -y libxfixes-dev:i386` <br>
`sudo apt install -y x11proto-dev:i386` <br>
`sudo apt install -y libxcb-glx0-dev:i386` <br>
`sudo apt install -y libxcb-shm0-dev:i386` <br>
`sudo apt install -y libx11-xcb-dev:i386` <br>
`sudo apt install -y libxcb-dri2-0-dev:i386` <br>
`sudo apt install -y libxcb-dri3-dev:i386` <br>
`sudo apt install -y libxcb-present-dev:i386` <br>
`sudo apt install -y Flibxshmfence-dev:i386` <br>
`sudo apt install -y libxxf86vm-dev:i386` <br>
`sudo apt install -y libxrandr-dev:i386` <br>
`sudo apt install -y libunwind-dev:i386` <br>
`sudo apt install -y libelf-dev:i386` <br>
`sudo apt install -y libzstd-dev:i386` <br>
`sudo apt install -y libbsd-dev:i386` <br>
`sudo apt install -y libsensors-dev:i386` <br>
`sudo apt install -y libxcb-keysyms1-dev:i386` <br>
`sudo apt install -y libva-dev:i386` <br>
`sudo apt install -y libxshmfence-dev:i386` <br>
<br>
meson setup --reconfigure build32 \
  --cross-file ~/.local/share/meson/cross/gcc-i686 \
  --wrap-mode=nofallback \
  -Dprefix=/usr \
  -Dglx=dri \
  -Degl=enabled \
  -Dgbm=enabled \
  -Dgallium-vdpau=disabled \
  -Dvalgrind=disabled \
  -Dgallium-drivers=virgl,zink \
  -Dvulkan-drivers=virtio \
  -Dvulkan-layers=device-select
<br>
  sudo ninja -C build32 install
<br>
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.i686.json:/usr/share/vulkan/icd.d/virtio_icd.json:/usr/share/vulkan/icd.d/virtio_icd.x86_64.json
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLSL_VERSION_OVERRIDE=460
export MESA_GLES_VERSION_OVERRIDE=3.2
<br>
source ~/.bashrc
<br>
sudo mv /usr/share/vulkan/explicit_layer.d/VkLayer_INTEL_nullhw.json /usr/share/vulkan/explicit_layer.d/VkLayer_INTEL_nullhw.json.disabled

<br><br>

# ARM:<br>

Venus for ARM on Crostini

Back up your VM please. 32 bit driver not added yet.

sudo apt install nano
sudo nano /etc/apt/sources.list

deb-src [arch=arm64] http://deb.debian.org/debian sid main
deb http://http.us.debian.org/debian sid main non-free contrib


sudo dpkg --add-architecture arm64
sudo apt update
sudo apt install -y vulkan-tools
sudo apt install -y libepoxy-dev
sudo apt install -y libvulkan-dev
sudo apt install -y python3-yaml
sudo apt install -y git
sudo apt install -y meson
sudo apt install -y pkg-config
sudo apt install -y zstd tar
sudo apt install -y mesa-utils
sudo apt install -y cmake
sudo apt install -y pkg-config cmake
sudo apt install -y vulkan-validationlayers
sudo apt install -y libunwind-dev
sudo apt install -y libdisplay-info-dev
sudo apt install -y hwdata
sudo apt install -y llvm
sudo apt install -y llvm-dev
sudo apt install -y lua5.4
sudo apt install -y liblua5.4-dev


cd ~
mkdir venus
cd venus
git clone https://gitlab.freedesktop.org/mesa/mesa.git
sudo apt-get build-dep mesa -y
cd ~/venus/mesa
git pull origin


meson setup --reconfigure build64 \
  --libdir /usr/lib/aarch64-linux-gnu \
  --wrap-mode=nofallback \
  -Dllvm=enabled \
  -Dprefix=/usr \
  -Dgallium-drivers=virgl,zink \
  -Dvulkan-drivers=virtio \
  -Dvulkan-layers=device-select \
  -Dglx=dri \
  -Degl=enabled \
  -Dgbm=enabled \
  -Dgallium-vdpau=disabled \
  -Dvalgrind=disabled

  sudo ninja -C build64 install

  VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/virtio_icd.aarch64.json
  source ~/.bashrc
  



