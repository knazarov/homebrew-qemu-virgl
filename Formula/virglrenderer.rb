class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  url "https://github.com/akihikodaki/virglrenderer.git", revision: "23f309ff0cf677b16d44c62f72ff01a84f845962"
  version "20220219.1"
  license "MIT"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "akirakyle/qemu-virgl/libangle"
  depends_on "akirakyle/qemu-virgl/libepoxy-angle"

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
