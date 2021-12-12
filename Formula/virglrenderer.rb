class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  url "https://gitlab.freedesktop.org/virgl/virglrenderer.git", revision: "453017e32ace65fa2f9c908bd5a9721f65fbf2a2"
  version "20211212.1"
  license "MIT"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/virglrenderer-20210428.1"
    sha256 cellar: :any, catalina: "5d096a7c2df87f390b3151a178cf750948a186260dc57eeb09feb9ea507f6035"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "knazarov/qemu-virgl/libangle"
  depends_on "knazarov/qemu-virgl/libepoxy-angle"

  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/d8e807a58717d551ecb73a6e721e49559cec1a3d/Patches/virglrenderer-v04.diff"
    sha256 "cb9e2ea4d73cd99375bd9fc9a008f4d7e53249a6259d63ff8f367a08c4fd8b9c"
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
