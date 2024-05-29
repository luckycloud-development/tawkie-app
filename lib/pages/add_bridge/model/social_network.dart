import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SocialNetwork {
  final Widget logo; // The path to social media image
  final String name; // Social media name
  final String chatBot; // ChatBot for send demand
  final String? urlLogin;
  final String? urlRedirect;
  bool? loading; // To find out if state is loading
  bool? connected; // To find out if state is disconnected
  bool error; // Bool to indicate if there is an error

  SocialNetwork({
    required this.logo,
    required this.name,
    required this.chatBot,
    this.urlLogin,
    this.urlRedirect,
    this.loading = true, // Default value true for loading
    this.connected = false, // Default value false for connected
    this.error = false, // Défaut à false
  });

  // How to update connection results
  void updateConnectionResult(bool connectedValue) {
    loading = false;
    connected = connectedValue;
  }

  // Error update
  void setError(bool errorValue) {
    loading = false;
    error = errorValue;
  }
}

final List<SocialNetwork> socialNetwork = [
  SocialNetwork(
    logo: Logo(Logos.facebook_messenger),
    name: "Facebook Messenger",
    chatBot: "@messenger2bot:",
    urlLogin: "https://www.messenger.com/",
    urlRedirect: "https://www.messenger.com/t/",
  ),
  SocialNetwork(
    logo: Logo(Logos.instagram),
    name: "Instagram",
    chatBot: "@instagram2bot:",
    urlLogin: "https://www.instagram.com/accounts/login/",
    urlRedirect: "https://www.instagram.com/",
  ),
  SocialNetwork(
    logo: Logo(Logos.whatsapp),
    name: "WhatsApp",
    chatBot: "@whatsappbot:",
  ),
  SocialNetwork(
    logo: Logo(Logos.linkedin),
    name: "Linkedin",
    chatBot: "@linkedinbot:alpha.tawkie.fr",
    urlLogin: "https://www.linkedin.com/login/",
    urlRedirect: "https://www.linkedin.com/feed/",
  ),
];

// Model for WhatsApp message response
class WhatsAppResult {
  final String result;
  final String? code;
  final String? qrCode;

  WhatsAppResult(this.result, this.code, this.qrCode);
}
