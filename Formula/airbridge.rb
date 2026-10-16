class Airbridge < Formula
  desc "AirScan (eSCL) and AirPrint for printers and scanners that lack them"
  homepage "https://github.com/tobhoster/airbridge"
  url "https://github.com/tobhoster/airbridge/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "28dcfc5c17ce7114d2a967433229922dd6bccb94b734a1c0402a7ae8bd91e701"
  license any_of: ["MIT", "Apache-2.0"]
  head "https://github.com/tobhoster/airbridge.git", branch: "main"

  # airbridge serves scanners and printers to the Macs on a LAN; it runs on the
  # Linux box next to them (it watches addresses through netlink).
  depends_on "nasm" => :build
  depends_on "rust" => :build
  depends_on :linux
  depends_on "sane-backends"

  def install
    system "cargo", "install", *std_cargo_args
    libexec.install bin/"airbridge"
    # Use Homebrew's SANE unless the user points at another libsane (e.g. the
    # system one, to reach backends such as Brother's brscan4).
    (bin/"airbridge").write <<~SH
      #!/bin/sh
      AIRBRIDGE_LIBSANE="${AIRBRIDGE_LIBSANE:-#{Formula["sane-backends"].opt_lib}/libsane.so.1}"
      export AIRBRIDGE_LIBSANE
      exec "#{libexec}/airbridge" "$@"
    SH
  end

  service do
    run [opt_bin/"airbridge"]
    keep_alive true
    environment_variables RUST_LOG: "info,mdns_sd=warn"
    log_path var/"log/airbridge.log"
    error_log_path var/"log/airbridge.log"
  end

  test do
    port = free_port
    ENV["AIRBRIDGE_PORT"] = port.to_s
    ENV["AIRBRIDGE_BACKEND"] = "fake"
    ENV["AIRBRIDGE_PRINTING"] = "off"
    # Serve and announce on loopback only: the test must not show a demo
    # scanner to every Mac on the network.
    ENV["AIRBRIDGE_INTERFACES"] = "lo"
    pid = spawn bin/"airbridge"
    begin
      sleep 3
      system bin/"airbridge", "healthcheck"
      assert_equal 0, $CHILD_STATUS.exitstatus
      caps = shell_output("curl -s http://127.0.0.1:#{port}/eSCL/ScannerCapabilities")
      assert_match "<pwg:MakeAndModel>Airbridge Demo Scanner</pwg:MakeAndModel>", caps
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
