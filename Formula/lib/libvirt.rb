class Libvirt < Formula
  desc "C virtualization API"
  homepage "https://libvirt.org/"
  url "https://download.libvirt.org/libvirt-11.0.0.tar.xz"
  sha256 "01a176ff4042ad58cf83c09fe0925d6bc8eed0ecce1e0ee19b8ef4c1ffa3806e"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://gitlab.com/libvirt/libvirt.git", branch: "master"

  livecheck do
    url "https://download.libvirt.org"
    regex(/href=.*?libvirt[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sequoia: "15426fa6e8f2cd3a47712c3c03a459d8f2f5d61ba25e7efb914bcef4df160175"
    sha256 arm64_sonoma:  "2b4fd22a9da0135432d0b90f4f14b9ca2606471dc104e665994cfb64fc148863"
    sha256 arm64_ventura: "ba956771e23c62aab80c6ea5726183f83a8626b70db1b6532201204a8f12d4a9"
    sha256 sonoma:        "8fe072fe12eca1c590474a08baaa2747e67ac3460aaa278960d0133c49eaf2ff"
    sha256 ventura:       "9c95359ab212b5744897da183502624cd680cebf3d52592e2d0028ab6ce082df"
    sha256 x86_64_linux:  "6d90ff6608ceb0f9158df4bc2d8bd9725c825ba012518d10c1b93ff3db7ffe15"
  end

  depends_on "docutils" => :build
  depends_on "gettext" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "glib"
  depends_on "gnutls"
  depends_on "json-c"
  depends_on "libgcrypt"
  depends_on "libiscsi"
  depends_on "libssh2"
  depends_on "readline" # Possible opportunistic linkage. TODO: Check if this can be removed.
  depends_on "yajl"

  uses_from_macos "perl" => :build
  uses_from_macos "curl"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_macos do
    depends_on "gettext"
  end

  on_linux do
    depends_on "acl"
    depends_on "libnl"
    depends_on "libtirpc"
    depends_on "util-linux"
  end

  def install
    args = %W[
      --localstatedir=#{var}
      --mandir=#{man}
      --sysconfdir=#{etc}
      -Ddriver_esx=enabled
      -Ddriver_qemu=enabled
      -Ddriver_network=enabled
      -Dinit_script=none
      -Dqemu_datadir=#{Formula["qemu"].opt_pkgshare}
    ]
    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  service do
    run [opt_sbin/"libvirtd", "-f", etc/"libvirt/libvirtd.conf"]
    keep_alive true
    environment_variables PATH: HOMEBREW_PREFIX/"bin"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/virsh -v")
  end
end
