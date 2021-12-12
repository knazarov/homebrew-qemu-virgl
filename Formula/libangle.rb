class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/google/angle.git", using: :git, revision: "df0f7133799ca6aa0d31802b22d919c6197051cf"
  version "20211212.1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/libangle-20211212.1"
    sha256 cellar: :any, arm64_big_sur: "6e776fc996fa02df211ee7e79512d4996558447bde65a63d2c7578ed1f63f660"
    sha256 cellar: :any, big_sur: "1c201f77bb6d877f2404ec761e47e13b97a3d61dff7ddfc484caa3deae4e5c1b"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git", revision: "dc86a4b9044f9243886ca0da0c1753820ac51f45"
  end

  def install
    mkdir "build" do
      resource("depot_tools").stage do
        path = PATH.new(ENV["PATH"], Dir.pwd)
        with_env(PATH: path) do
          Dir.chdir(buildpath)

          system "python2", "scripts/bootstrap.py"
          system "gclient", "sync"
          if Hardware::CPU.arm?
            system "gn", "gen", \
              "--args=use_custom_libcxx=false target_cpu=\"arm64\" treat_warnings_as_errors=false", \
              "./angle_build"
          else
            system "gn", "gen", "--args=use_custom_libcxx=false treat_warnings_as_errors=false", "./angle_build"
          end
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
