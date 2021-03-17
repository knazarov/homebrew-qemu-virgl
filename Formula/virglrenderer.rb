class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  url "https://github.com/freedesktop/virglrenderer.git", using: :git, revision: "d470a2df588d86fca460db889bfe5b2cce7caebb"
  version "20210315.1"
  license "MIT"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/virglrenderer-20210315.1"
    sha256 cellar: :any, catalina: "8e0a2dd913ed12a74b5379c7c24620bce2c2b30b00896703d1f09656d34a47b2"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "knazarov/qemu-virgl/libangle"
  depends_on "knazarov/qemu-virgl/libepoxy-angle"

  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/e6d2da200586ab412791d80ef38abbeb335afa3d/Patches/virglrenderer-v01.diff"
    sha256 "44d745753459315733e4a2fff2e6bd731a85cc9250ac89c734f8a81dda17ce09"
  end

  def install
    mkdir "build" do
      system "meson", *std_meson_args, "-Dc_args=-I#{Formula["libepoxy-angle"].opt_prefix}/include",
             "-Dc_link_args=-L#{Formula["libepoxy-angle"].opt_prefix}/lib", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    system "true"
  end
end
