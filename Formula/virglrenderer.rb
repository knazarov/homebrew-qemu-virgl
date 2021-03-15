# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  url "https://github.com/freedesktop/virglrenderer.git", :using => :git, :revision => "d470a2df588d86fca460db889bfe5b2cce7caebb"
  license "MIT"
  version "20210315.1"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "knazarov/qemu-virgl/libepoxy-angle"
  depends_on "knazarov/qemu-virgl/libangle"

  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  patch :p1 do
    url "https://raw.githubusercontent.com/knazarov/homebrew-qemu-virgl/master/Patches/virglrenderer-v01.diff"
    sha256 "44d745753459315733e4a2fff2e6bd731a85cc9250ac89c734f8a81dda17ce09"
  end

  def install
    # ENV.deparallelize  # if your formula fails when building in parallel
    mkdir "build" do
      system "meson", *std_meson_args, "-Dc_args=-I#{Formula["libepoxy-angle"].opt_prefix}/include", "-Dc_link_args=-L#{Formula['libepoxy-angle'].opt_prefix}/lib", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test virglrenderer`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
