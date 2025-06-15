{ pkgs, ... }:
{
  networking.nameservers = [ "192.168.30.102" ];

  security.pki.certificates = [
    ''
        -----BEGIN CERTIFICATE-----
      MIIDEjCCAfqgAwIBAgIRAIKVPtKhHCiggFAS092ngAMwDQYJKoZIhvcNAQELBQAw
      HDEaMBgGA1UEAwwRKi55b3VyLWRvbWFpbi5jb20wHhcNMjUwNjExMjEzMzI1WhcN
      MjUwOTA5MjEzMzI1WjAcMRowGAYDVQQDDBEqLnlvdXItZG9tYWluLmNvbTCCASIw
      DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKTN7XdSvzTNB3E75AuDcRvTpjFo
      wOtsOWGMlK6M3jJUlYayFOcPTbbmb8B7WnQhIgmLoIkpbp38RfatjjhBSKT5TUIJ
      N1p6Z/Ki2ZEN5jHKIcEMSf0Jw1A6b5PM+/rgajajaY7bswPIxss8+M2It8vLL1ae
      +E+Ve84yoiFNLALVXXyNA9ewiNyePDDiRxoeO638aXI1PXM5eKyWfVNkupV0auET
      j6xzfAknJ8THFX5rnlD4q9UlawMWXihqXcQYiE7yWEKk4mcJF2jtoysDd8ibZdwQ
      vBGXUn8tVoeWpdCm8jBNuLJl65wUP/O0sA3Z9KXSSuNkGAQguwbM0gHuUK0CAwEA
      AaNPME0wDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwLQYDVR0RBCYwJIIR
      Ki55b3VyLWRvbWFpbi5jb22CD3lvdXItZG9tYWluLmNvbTANBgkqhkiG9w0BAQsF
      AAOCAQEAlYSqPjRMgo23L7W+rxd8s4Ea8mi6r78WSnzRfI4uPQZxJvyD7CSUGfKF
      6JbICr2nFsdJtSovOqCJX/GuGS1gPic18bQnlSCPgYTvmkbzWretoz63BNqnfD71
      feI0A6IvuDXQgPvk3d60D1uRA+/FKF4ejqYO7EKnA95UJZNPuuxU5EXR+oI+W2tt
      5xxBSFrLcqWJ1zHFNinXt5ESfwVvzGWozQ4ljXL5/Aa/4k6fJzsBH6dOV708j1IC
      BUlpTYGy3CfpyF6WMHW6z/xb4NngZSaDwAu8esUXCn2y0gU6KIk3Evglm/DiF45s
      WsIo7ZTso7d0IuZm51jqjH/UeVh5FQ==
      -----END CERTIFICATE-----
    ''
  ];

  environment = {
    variables.EDITOR = "hx";
    systemPackages = with pkgs; [ helix ];
  };
}
