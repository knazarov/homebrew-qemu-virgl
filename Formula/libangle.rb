class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/google/angle.git", using: :git, revision: "a11d65a172f885042cf4fdab5bfd124d174f5190"
  version "20210315.1"
  license "BSD-3-Clause"

  depends_on "meson" => :build
  depends_on "ninja" => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git", revision: "8e2667e04d9282b6cb24e1086a246247036393c5"
  end

  def install
    mkdir "build" do
      resource("depot_tools").stage do
        path = PATH.new(ENV["PATH"], Dir.pwd)
        with_env(PATH: path) do
          Dir.chdir(buildpath)

          system "python2", "scripts/bootstrap.py"
          system "gclient", "sync"
          system "gn", "gen", "--args=use_custom_libcxx=false", "./angle_build"
          system "ninja", "-C", "angle_build"
          lib.install "angle_build/libabsl.dylib"
          lib.install "angle_build/libEGL.dylib"
          lib.install "angle_build/libGLESv2.dylib"
          lib.install "angle_build/libchrome_zlib.dylib"
          include.install Pathname.glob("include/*")
        end
      end
    end
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test libangle`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
