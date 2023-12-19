import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/io.dart';
import 'package:omar_aad_oauth/model/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart' ;
import 'model/config.dart';
import 'model/token.dart';
import 'request/token_refresh_request.dart';
import 'request/token_request.dart';

class RequestToken {
  final Config config;

  RequestToken(this.config){
    _fixCertificateProblem();
  }

  Future<Either<Failure, Token>> requestToken(String code) async {
    final _tokenRequest = TokenRequestDetails(config, code);
    return await _sendTokenRequest(
        _tokenRequest.url, _tokenRequest.params, _tokenRequest.headers);
  }

  Future<Either<Failure, Token>> requestRefreshToken(
      String refreshToken) async {
    final _tokenRefreshRequest =
        TokenRefreshRequestDetails(config, refreshToken);
    return await _sendTokenRequest(_tokenRefreshRequest.url,
        _tokenRefreshRequest.params, _tokenRefreshRequest.headers);
  }

  Dio dio = Dio(
    BaseOptions(
      headers: {
        "Accept": "application/json",
        'content-Type': 'application/json',
      },
    ),
  );

  void _fixCertificateProblem(){
    const fingerprint = 'ee5ce1dfa7a53657c545c62b65802e4272878dabd65c0aadcf85783ebb0b4d5c';
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final client = HttpClient(context: SecurityContext(withTrustedRoots: true));
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
      // validateCertificate: (cert, host, port) {
      //   // Check that the cert fingerprint matches the one we expect.
      //   // We definitely require _some_ certificate.
      //   if (cert == null) {
      //     return false;
      //   }
      //   // Validate it any way you want. Here we only check that
      //   // the fingerprint matches the OpenSSL SHA256.
      //   return fingerprint == sha256.convert(cert.der).toString();
      // },
    );
  }

  Future<Either<Failure, Token>> _sendTokenRequest(String url,
      Map<String, String> params, Map<String, String> headers) async {
    try {
      log("posting request for token");

      var response = await dio.post(url, data: params, options: Options(headers:headers),);
      log(response.data.toString());
      var token = Token.fromJson(response.data);
      return Right(token);
      return Left(
          RequestFailure(ErrorType.InvalidJson, 'Token json is invalid'));
    } catch (e) {
      return Left(RequestFailure(
          ErrorType.InvalidJson, 'Token json is invalid: ${e.toString()}'));
    }
  }
}
