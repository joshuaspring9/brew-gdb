class Gdb < Formula
    desc "GNU debugger"
    homepage "https://www.gnu.org/software/gdb/"
    url "https://ftp.gnu.org/gnu/gdb/gdb-8.0.1.tar.xz"
    mirror "https://ftpmirror.gnu.org/gdb/gdb-8.0.1.tar.xz"
    sha256 "3dbd5f93e36ba2815ad0efab030dcd0c7b211d7b353a40a53f4c02d7d56295e3"
    revision 1
  
    bottle do
      sha256 "e98ad847402592bd48a9b1468fefb2fac32aff1fa19c2681c3cea7fb457baaa0" => :high_sierra
      sha256 "0fdd20562170c520cfb16e63d902c13a01ec468cb39a85851412e7515b6241e9" => :sierra
      sha256 "f51136c70cff44167dfb8c76b679292d911bd134c2de3fef40777da5f1f308a0" => :el_capitan
      sha256 "2b32a51703f6e254572c55575f08f1e0c7bc2f4e96778cb1fa6582eddfb1d113" => :yosemite
    end
  
    deprecated_option "with-brewed-python" => "with-python"
    deprecated_option "with-guile" => "with-guile@2.0"
  
    option "with-python", "Use the Homebrew version of Python; by default system Python is used"
    option "with-version-suffix", "Add a version suffix to program"
    option "with-all-targets", "Build with support for all targets"
  
    depends_on "pkg-config" => :build
    depends_on "python" => :optional
    depends_on "guile@2.0" => :optional
  
    fails_with :clang do
      build 600
      cause <<~EOS
        clang: error: unable to execute command: Segmentation fault: 11
        Test done on: Apple LLVM version 6.0 (clang-600.0.56) (based on LLVM 3.5svn)
      EOS
    end

    # Fix build with all targets. Remove if 8.2.1+
    # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;a=commitdiff;h=0c0a40e0abb9f1a584330a1911ad06b3686e5361
    patch do
        url "https://raw.githubusercontent.com/Homebrew/formula-patches/d457e55/gdb/all-targets.diff"
        sha256 "1cb8a1b8c4b4833212e16ba8cfbe620843aba0cba0f5111c2728c3314e10d8fd"
    end

    # Fix debugging of executables of Xcode 10 and later
    # created for 10.14 and newer versions of macOS. Remove if 8.2.1+
    # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;h=fc7b364aba41819a5d74ae0ac69f050af282d057
    patch do
        url "https://raw.githubusercontent.com/Homebrew/formula-patches/d457e55/gdb/mojave.diff"
        sha256 "6264c71b57a0d5d4aed11430d352b03639370b7d36a5b520e189a6a1f105e383"
    end
  
    def install
      args = [
        "--prefix=#{prefix}",
        "--disable-debug",
        "--disable-dependency-tracking",
      ]
  
      args << "--with-guile" if build.with? "guile@2.0"
      args << "--enable-targets=all" if build.with? "all-targets"
  
      if build.with? "python"
        args << "--with-python=#{HOMEBREW_PREFIX}"
      else
        args << "--with-python=/usr"
      end
  
      if build.with? "version-suffix"
        args << "--program-suffix=-#{version.to_s.slice(/^\d/)}"
      end
  
      system "./configure", *args
      system "make"
  
      # Don't install bfd or opcodes, as they are provided by binutils
      inreplace ["bfd/Makefile", "opcodes/Makefile"], /^install:/, "dontinstall:"
  
      system "make", "install"
    end
  
    def caveats; <<~EOS
      gdb requires special privileges to access Mach ports.
      You will need to codesign the binary. For instructions, see:
  
        https://sourceware.org/gdb/wiki/BuildingOnDarwin
  
      On 10.12 (Sierra) or later with SIP, you need to run this:
  
        echo "set startup-with-shell off" >> ~/.gdbinit
      EOS
    end
  
    test do
      system bin/"gdb", bin/"gdb", "-configuration"
    end
  end