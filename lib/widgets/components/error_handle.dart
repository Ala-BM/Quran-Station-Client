import 'package:flutter/material.dart';
import 'package:theway/Services/qsscrapper.dart';
import 'package:theway/l10n/app_localizations.dart';

class ErrorHandle extends StatefulWidget {
  final VoidCallback? onRetry;
  final Object? error;

  const ErrorHandle({
    super.key,
    this.onRetry,
    this.error,
  });

  @override
  State<ErrorHandle> createState() => _ErrorHandleState();
}

class _ErrorHandleState extends State<ErrorHandle> {
  Future<List<dynamic>>? srcAudios;

  @override
  Widget build(BuildContext context) {
    return _buildErrorWidget(context, widget.error);
  }

  Widget _buildErrorWidget(BuildContext context, Object? error) {
  
    if (error is QSScrapperException) {
      return _buildQSErrorWidget(context, error);
    }

    return _buildGenericErrorWidget(context, error);
  }

  Widget _buildQSErrorWidget(BuildContext context, QSScrapperException error) {
    IconData icon;
    String title;
    String subtitle;
    Color color;
    bool showRetryButton = true;
    
    switch (error.type) {
      case QSErrorType.hostLookupFailed:
        icon = Icons.dns_outlined;
        title = AppLocalizations.of(context)!.translate("Connection Failed");
        subtitle = AppLocalizations.of(context)!.translate("Cannot reach server. Please check your internet connection.");
        color = Colors.red;
        break;
        
      case QSErrorType.timeoutError:
        icon = Icons.access_time_outlined;
        title = AppLocalizations.of(context)!.translate("Request Timeout");
        subtitle = AppLocalizations.of(context)!.translate("The request took too long. Please try again.");
        color = Colors.orange;
        break;
        
      case QSErrorType.networkError:
      case QSErrorType.noInternetConnection:
        icon = Icons.wifi_off_outlined;
        title = AppLocalizations.of(context)!.translate("No Internet");
        subtitle = AppLocalizations.of(context)!.translate("Please check your internet connection and try again.");
        color = Colors.red;
        break;
        
      case QSErrorType.serverError:
        icon = Icons.error_outline;
        title = AppLocalizations.of(context)!.translate("Server Error");
        subtitle = AppLocalizations.of(context)!.translate("The server is experiencing issues. Please try again later.");
        color = Colors.red;
        break;
        
      case QSErrorType.dataNotFound:
        icon = Icons.search_off_outlined;
        title = AppLocalizations.of(context)!.translate("No Data Found");
        subtitle = AppLocalizations.of(context)!.translate("The requested content is not available.");
        color = Colors.grey;
        showRetryButton = false;
        break;
        
      case QSErrorType.dataParsingError:
        icon = Icons.broken_image_outlined;
        title = AppLocalizations.of(context)!.translate("Data Error");
        subtitle = AppLocalizations.of(context)!.translate("There was an issue processing the data. Please try again.");
        color = Colors.red;
        break;
        
      default:
        icon = Icons.error_outline;
        title = AppLocalizations.of(context)!.translate("Something Went Wrong");
        subtitle = error.message;
        color = Colors.red;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  _refreshData();
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.translate("Try Again")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _showErrorDetails(context, error);
              },
              child: Text(
                AppLocalizations.of(context)!.translate("Show Details"),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericErrorWidget(BuildContext context, Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.translate("Something Went Wrong"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate("An unexpected error occurred. Please try again."),
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _refreshData();
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.translate("Try Again")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshData() {
    if (widget.onRetry != null) {
      widget.onRetry!();
    } else {
      setState(() {
      });
    }
  }

  void _showErrorDetails(BuildContext context, QSScrapperException error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate("Error Details")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate("Error Type:"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(error.type.toString()),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate("Message:"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(error.message),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.translate("Close")),
          ),
        ],
      ),
    );
  }
}