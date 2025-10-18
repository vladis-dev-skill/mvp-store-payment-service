<?php

namespace App\Controller\InnerApi;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

#[Route('/inner-api/payment')]
class PaymentController extends AbstractController
{
    public function __construct() {}

    #[Route('/health', name: 'payment_health', methods: ['GET'])]
    public function health(): JsonResponse
    {
        return $this->json([
            'status' => 'ok',
            'service' => 'payment-service',
            'timestamp' => (new \DateTime())->format('Y-m-d H:i:s')
        ]);
    }
}