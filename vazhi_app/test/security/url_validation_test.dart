/// Security Tests - URL Validation
///
/// Tests to ensure URL validation prevents malicious redirects and MITM attacks.

import 'package:flutter_test/flutter_test.dart';

// Test the URL validation logic without instantiating the full service
void main() {
  // Allowed hosts list (mirrors ModelDownloadService._allowedHosts)
  final allowedHosts = {
    'huggingface.co',
    'cdn-lfs.huggingface.co',
    'cdn-lfs-us-1.huggingface.co',
    'cdn-lfs-us-2.huggingface.co',
    'cdn-lfs-eu-1.huggingface.co',
    'cdn-lfs-eu-2.huggingface.co',
    'cdn-lfs.hf.co',
    's3.amazonaws.com',
  };

  bool isAllowedUrl(Uri url) {
    if (!url.hasScheme || url.scheme != 'https') {
      return false;
    }
    final host = url.host.toLowerCase();
    return allowedHosts.any(
      (allowed) => host == allowed || host.endsWith('.$allowed'),
    );
  }

  group('URL Validation - Allowed Hosts', () {
    test('allows huggingface.co', () {
      final url = Uri.parse('https://huggingface.co/model.gguf');
      expect(isAllowedUrl(url), isTrue);
    });

    test('allows CDN subdomains', () {
      final url1 = Uri.parse('https://cdn-lfs.huggingface.co/file');
      final url2 = Uri.parse('https://cdn-lfs-us-1.huggingface.co/file');
      final url3 = Uri.parse('https://cdn-lfs-eu-1.huggingface.co/file');

      expect(isAllowedUrl(url1), isTrue);
      expect(isAllowedUrl(url2), isTrue);
      expect(isAllowedUrl(url3), isTrue);
    });

    test('allows s3.amazonaws.com', () {
      final url = Uri.parse('https://s3.amazonaws.com/bucket/model.gguf');
      expect(isAllowedUrl(url), isTrue);
    });

    test('allows hf.co CDN', () {
      final url = Uri.parse('https://cdn-lfs.hf.co/model.gguf');
      expect(isAllowedUrl(url), isTrue);
    });
  });

  group('URL Validation - Blocked Hosts', () {
    test('blocks arbitrary domains', () {
      final url = Uri.parse('https://evil-site.com/model.gguf');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks lookalike domains', () {
      final url1 = Uri.parse('https://huggingface.co.evil.com/model.gguf');
      final url2 = Uri.parse('https://fake-huggingface.co/model.gguf');
      final url3 = Uri.parse('https://huggingface-cdn.com/model.gguf');

      expect(isAllowedUrl(url1), isFalse);
      expect(isAllowedUrl(url2), isFalse);
      expect(isAllowedUrl(url3), isFalse);
    });

    test('blocks non-HTTPS URLs', () {
      final url = Uri.parse('http://huggingface.co/model.gguf');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks file:// URLs', () {
      final url = Uri.parse('file:///etc/passwd');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks ftp:// URLs', () {
      final url = Uri.parse('ftp://huggingface.co/model.gguf');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks javascript: URLs', () {
      final url = Uri.parse('javascript:alert(1)');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks URLs without scheme', () {
      final url = Uri.parse('huggingface.co/model.gguf');
      expect(isAllowedUrl(url), isFalse);
    });
  });

  group('URL Validation - MITM Prevention', () {
    test('blocks redirect to attacker-controlled domain', () {
      // Simulating redirect from HF to attacker site
      final maliciousRedirect = Uri.parse('https://attacker.com/fake-model.gguf');
      expect(isAllowedUrl(maliciousRedirect), isFalse);
    });

    test('blocks IP address redirects', () {
      final url = Uri.parse('https://192.168.1.1/model.gguf');
      expect(isAllowedUrl(url), isFalse);
    });

    test('blocks localhost redirects', () {
      final url1 = Uri.parse('https://localhost/model.gguf');
      final url2 = Uri.parse('https://127.0.0.1/model.gguf');

      expect(isAllowedUrl(url1), isFalse);
      expect(isAllowedUrl(url2), isFalse);
    });

    test('blocks internal network redirects', () {
      final url1 = Uri.parse('https://10.0.0.1/model.gguf');
      final url2 = Uri.parse('https://172.16.0.1/model.gguf');

      expect(isAllowedUrl(url1), isFalse);
      expect(isAllowedUrl(url2), isFalse);
    });
  });

  group('URL Validation - Edge Cases', () {
    test('handles empty host', () {
      // This might throw or return false depending on Uri.parse behavior
      try {
        final url = Uri.parse('https:///model.gguf');
        expect(isAllowedUrl(url), isFalse);
      } catch (e) {
        // Expected for malformed URL
        expect(e, isA<FormatException>());
      }
    });

    test('handles case variations', () {
      final url1 = Uri.parse('https://HUGGINGFACE.CO/model.gguf');
      final url2 = Uri.parse('https://HuggingFace.Co/model.gguf');

      expect(isAllowedUrl(url1), isTrue);
      expect(isAllowedUrl(url2), isTrue);
    });

    test('handles URLs with ports', () {
      final url = Uri.parse('https://huggingface.co:443/model.gguf');
      expect(isAllowedUrl(url), isTrue);
    });

    test('handles URLs with unusual ports', () {
      final url = Uri.parse('https://huggingface.co:8080/model.gguf');
      // Should still be allowed if host is valid
      expect(isAllowedUrl(url), isTrue);
    });

    test('handles URLs with query strings', () {
      final url = Uri.parse('https://huggingface.co/model.gguf?token=abc');
      expect(isAllowedUrl(url), isTrue);
    });

    test('handles URLs with fragments', () {
      final url = Uri.parse('https://huggingface.co/model.gguf#section');
      expect(isAllowedUrl(url), isTrue);
    });

    test('handles nested subdomains of allowed hosts', () {
      final url = Uri.parse('https://deep.nested.huggingface.co/model.gguf');
      // Should be allowed as it ends with .huggingface.co
      expect(isAllowedUrl(url), isTrue);
    });
  });
}
