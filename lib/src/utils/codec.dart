import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:decorated_flutter/src/utils/log.dart';
import 'package:encrypt/encrypt.dart';

class Codec {
  static Codec _instance;
  static Encrypter _aes;

  Codec._();

  factory Codec({String aesKey}) {
    if (_instance == null) {
      _instance = Codec._();
      _aes = Encrypter(
        AES(Key.fromUtf8(aesKey), mode: AESMode.cbc),
      );
      return _instance;
    } else {
      return _instance;
    }
  }

  /// dynamic是因为jsonDecode返回无法确定是什么类型, 其他的都是String
  dynamic _output;

  dynamic get() => _output;

  Codec base64Encode([String target]) {
    L.p('base64Encode前: ${target ?? _output} 结束');
    _output = base64.encode(utf8.encode(target) ?? _output.codeUnits);
    L.p('base64Encode后: $_output 结束');
    return this;
  }

  Codec base64Decode([String target]) {
    L.p('base64Decode前: ${target ?? _output} 结束');
    _output = utf8.decode(base64.decode(target ?? _output));
    L.p('base64Decode后: $_output 结束');
    return this;
  }

  Codec jsonEncode([dynamic target]) {
    L.p('jsonEncode前: ${target ?? _output} 结束');
    _output = json.encode(target ?? _output);
    L.p('jsonEncode后: $_output 结束');
    return this;
  }

  Codec jsonDecode([String target]) {
    L.p('jsonDecode前: ${target ?? _output} 结束');
    _output = json.decode(target ?? _output);
    L.p('jsonDecode后: $_output 结束');
    return this;
  }

  Codec urlEncode([String target]) {
    L.p('urlEncode前: ${target ?? _output} 结束');
    _output = Uri.encodeFull(target ?? _output);
    L.p('urlEncode后: $_output 结束');
    return this;
  }

  Codec urlDecode([String target]) {
    L.p('urlDecode前: ${target ?? _output} 结束');
    _output = Uri.decodeFull(target ?? _output);
    L.p('urlDecode后: $_output 结束');
    return this;
  }

  Codec aesEncrypt([String plainText, String aesIv]) {
    L.p('aesEncrypt前: ${plainText ?? _output} 结束');
    _output = _aes.encrypt(plainText ?? _output, iv: IV.fromUtf8(aesIv)).base64;
    L.p('aesEncrypt后: $_output 结束');
    return this;
  }

  Codec aesDecrypt([String base64Cipher, String aesIv]) {
    L.p('aesDecrypt前: ${base64Cipher ?? _output} 结束');
    _output = _aes.decrypt(
      Encrypted.fromBase64(base64Cipher ?? _output),
      iv: IV.fromUtf8(aesIv),
    );
    L.p('aesDecrypt后: $_output 结束');
    return this;
  }

  Codec md5([String seed]) {
    L.p('md5前: ${seed ?? _output} 结束');
    final seedCode = utf8.encode(seed ?? _output);
    _output = crypto.md5.convert(seedCode).toString();
    L.p('md5后: $_output 结束');
    return this;
  }

  Codec md5Bytes([List<int> seed]) {
    L.p('md5前: ${seed ?? _output} 结束');
    _output = crypto.md5.convert(seed ?? _output).toString();
    L.p('md5后: $_output 结束');
    return this;
  }
}
