class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/google/angle.git", using: :git, revision: "df0f7133799ca6aa0d31802b22d919c6197051cf"
  version "20211212.1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/knazarov/homebrew-qemu-virgl/releases/download/libangle-20210315.1"
    sha256 cellar: :any, arm64_big_sur: "0e7a61000a6c4e7f8050184c8b92a6c432f612a85e2c72d54c3888f18635fd61"
    sha256 cellar: :any, big_sur:       "e9aa9442083ef1eb5b3e760170d941b1ab4d8df521d97155afdf307619bd6351"
    sha256 cellar: :any, catalina:      "e9aa9442083ef1eb5b3e760170d941b1ab4d8df521d97155afdf307619bd6351"
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
            system "gn", "gen", "--args=use_custom_libcxx=false target_cpu=\"arm64\" treat_warnings_as_errors=false", "./angle_build"
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
