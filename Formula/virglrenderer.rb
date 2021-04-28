class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  url "https://gitlab.freedesktop.org/virgl/virglrenderer.git", using: :git, revision: "5e2d10463d6b79080c3376138221b73ea6e95186"
  version "20210404.1"
  license "MIT"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/virglrenderer-20210404.1"
    sha256 cellar: :any, catalina: "fdbbae2e42aed3e05515c7fd68df45b05a04aae4a08ceca1218998353c8727e7"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "knazarov/qemu-virgl/libangle"
  depends_on "knazarov/qemu-virgl/libepoxy-angle"

  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/381fdeb4ffe53196fe308852b3573a7ab2d2a2b9/Patches/virglrenderer-v03.diff"
    sha256 "45a0c32ed419a3440093efdd26d55810bfd6a4616bdeed9fc62db2fdd0c0a7f6"
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
