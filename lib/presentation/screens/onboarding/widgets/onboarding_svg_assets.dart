import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingSvgAssets {
  // AI Identification Illustration
  static Widget aiIdentificationSvg({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.string(
      '''
      <svg width="240" height="240" viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- Background Circle -->
        <circle cx="120" cy="120" r="100" fill="#ECF0F1" stroke="#B8860B" stroke-width="3"/>
        
        <!-- Coin -->
        <circle cx="120" cy="120" r="50" fill="#B8860B" stroke="#2C3E50" stroke-width="2"/>
        <circle cx="120" cy="120" r="35" fill="none" stroke="#2C3E50" stroke-width="1"/>
        <text x="120" y="130" font-family="Arial" font-size="24" font-weight="bold" text-anchor="middle" fill="#2C3E50">\$</text>
        
        <!-- AI Scan Lines -->
        <rect x="80" y="105" width="80" height="2" fill="#27AE60" opacity="0.8"/>
        <rect x="80" y="120" width="80" height="2" fill="#27AE60" opacity="0.6"/>
        <rect x="80" y="135" width="80" height="2" fill="#27AE60" opacity="0.4"/>
        
        <!-- Corner Brackets -->
        <path d="M70 70 L70 90 M70 70 L90 70" stroke="#27AE60" stroke-width="3" fill="none"/>
        <path d="M170 70 L170 90 M170 70 L150 70" stroke="#27AE60" stroke-width="3" fill="none"/>
        <path d="M70 170 L70 150 M70 170 L90 170" stroke="#27AE60" stroke-width="3" fill="none"/>
        <path d="M170 170 L170 150 M170 170 L150 170" stroke="#27AE60" stroke-width="3" fill="none"/>
        
        <!-- Digital Elements -->
        <circle cx="200" cy="60" r="4" fill="#3498DB"/>
        <circle cx="210" cy="50" r="3" fill="#3498DB" opacity="0.7"/>
        <circle cx="40" cy="180" r="4" fill="#3498DB"/>
        <circle cx="30" cy="190" r="3" fill="#3498DB" opacity="0.7"/>
      </svg>
      ''',
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // Collection Tracking Illustration
  static Widget collectionTrackingSvg({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.string(
      '''
      <svg width="240" height="240" viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- Portfolio/Folder Background -->
        <rect x="40" y="60" width="160" height="120" rx="12" fill="#ECF0F1" stroke="#B8860B" stroke-width="2"/>
        <rect x="40" y="60" width="160" height="30" rx="12" fill="#B8860B"/>
        
        <!-- Coins in Collection -->
        <circle cx="80" cy="120" r="20" fill="#B8860B" stroke="#2C3E50" stroke-width="1.5"/>
        <circle cx="120" cy="120" r="20" fill="#CD853F" stroke="#2C3E50" stroke-width="1.5"/>
        <circle cx="160" cy="120" r="20" fill="#95A5A6" stroke="#2C3E50" stroke-width="1.5"/>
        
        <!-- Value indicators -->
        <text x="80" y="125" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="#2C3E50">1¢</text>
        <text x="120" y="125" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="#2C3E50">5¢</text>
        <text x="160" y="125" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="#2C3E50">25¢</text>
        
        <!-- Statistics Chart -->
        <rect x="60" y="150" width="20" height="15" fill="#27AE60"/>
        <rect x="85" y="145" width="20" height="20" fill="#3498DB"/>
        <rect x="110" y="140" width="20" height="25" fill="#E74C3C"/>
        <rect x="135" y="135" width="20" height="30" fill="#F39C12"/>
        
        <!-- Total Value Display -->
        <rect x="50" y="190" width="140" height="25" rx="12" fill="#2C3E50"/>
        <text x="120" y="207" font-family="Arial" font-size="14" font-weight="bold" text-anchor="middle" fill="#B8860B">Total: \$47.50</text>
        
        <!-- Growth Arrow -->
        <path d="M170 110 L190 90 L185 95 L190 90 L185 85" stroke="#27AE60" stroke-width="3" fill="none"/>
      </svg>
      ''',
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // Market Prices Illustration
  static Widget marketPricesSvg({double? width, double? height, Color? color}) {
    return SvgPicture.string(
      '''
      <svg width="240" height="240" viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- Phone/Device Frame -->
        <rect x="60" y="40" width="120" height="160" rx="20" fill="#2C3E50" stroke="#B8860B" stroke-width="2"/>
        <rect x="70" y="60" width="100" height="120" rx="8" fill="#ECF0F1"/>
        
        <!-- Price Chart -->
        <polyline points="80,160 95,140 110,145 125,125 140,130 155,110 170,115" 
                  stroke="#27AE60" stroke-width="3" fill="none"/>
        
        <!-- Price Points -->
        <circle cx="95" cy="140" r="3" fill="#27AE60"/>
        <circle cx="125" cy="125" r="3" fill="#27AE60"/>
        <circle cx="155" cy="110" r="3" fill="#27AE60"/>
        
        <!-- Price Labels -->
        <text x="125" y="75" font-family="Arial" font-size="10" font-weight="bold" text-anchor="middle" fill="#2C3E50">Real-time Prices</text>
        
        <!-- Current Price Display -->
        <rect x="85" y="85" width="70" height="20" rx="4" fill="#B8860B"/>
        <text x="120" y="98" font-family="Arial" font-size="12" font-weight="bold" text-anchor="middle" fill="#2C3E50">\$125.40</text>
        
        <!-- Trend Indicators -->
        <path d="M85 170 L95 165 L90 167 L95 165 L90 163" stroke="#27AE60" stroke-width="2" fill="none"/>
        <text x="105" y="173" font-family="Arial" font-size="8" fill="#27AE60">+12.5%</text>
        
        <!-- Globe/Network Background -->
        <circle cx="120" cy="30" r="15" fill="none" stroke="#95A5A6" stroke-width="1" opacity="0.5"/>
        <path d="M105 30 Q120 20 135 30 Q120 40 105 30" stroke="#95A5A6" stroke-width="1" opacity="0.5" fill="none"/>
        <path d="M120 15 L120 45" stroke="#95A5A6" stroke-width="1" opacity="0.5"/>
        
        <!-- Data Points -->
        <circle cx="200" cy="60" r="2" fill="#3498DB" opacity="0.6"/>
        <circle cx="40" cy="160" r="2" fill="#3498DB" opacity="0.6"/>
        <circle cx="210" cy="180" r="2" fill="#3498DB" opacity="0.6"/>
      </svg>
      ''',
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // Secure Storage Illustration
  static Widget secureStorageSvg({
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.string(
      '''
      <svg width="240" height="240" viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- Vault/Safe Background -->
        <rect x="50" y="70" width="140" height="120" rx="15" fill="#2C3E50" stroke="#B8860B" stroke-width="3"/>
        
        <!-- Vault Door -->
        <circle cx="120" cy="130" r="35" fill="#ECF0F1" stroke="#95A5A6" stroke-width="2"/>
        <circle cx="120" cy="130" r="25" fill="none" stroke="#B8860B" stroke-width="2"/>
        
        <!-- Lock Mechanism -->
        <circle cx="120" cy="130" r="8" fill="#B8860B"/>
        <rect x="116" y="130" width="8" height="15" fill="#B8860B"/>
        
        <!-- Handle -->
        <circle cx="140" cy="130" r="6" fill="none" stroke="#95A5A6" stroke-width="2"/>
        
        <!-- Security Features -->
        <rect x="60" y="85" width="8" height="4" fill="#27AE60"/>
        <rect x="60" y="95" width="6" height="4" fill="#E74C3C"/>
        <rect x="60" y="105" width="10" height="4" fill="#3498DB"/>
        
        <!-- Digital Display -->
        <rect x="85" y="85" width="30" height="15" rx="3" fill="#000000"/>
        <text x="100" y="96" font-family="Arial" font-size="8" font-weight="bold" text-anchor="middle" fill="#27AE60">SECURE</text>
        
        <!-- Cloud Sync Icons -->
        <path d="M160 90 Q170 85 175 90 Q180 85 185 90 Q185 95 180 95 L165 95 Q160 95 160 90" 
              fill="#3498DB" opacity="0.7"/>
        <circle cx="172" cy="102" r="1.5" fill="#3498DB"/>
        <circle cx="177" cy="105" r="1" fill="#3498DB" opacity="0.5"/>
        
        <!-- Shield Icon -->
        <path d="M120 50 L130 55 L130 65 Q130 70 120 75 Q110 70 110 65 L110 55 Z" 
              fill="#27AE60" stroke="#2C3E50" stroke-width="1"/>
        <path d="M115 62 L118 65 L125 58" stroke="#ECF0F1" stroke-width="2" fill="none"/>
        
        <!-- Coins inside (partially visible) -->
        <circle cx="105" cy="145" r="8" fill="#B8860B" opacity="0.7"/>
        <circle cx="135" cy="140" r="8" fill="#CD853F" opacity="0.7"/>
      </svg>
      ''',
      width: width,
      height: height,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}
