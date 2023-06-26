#include<iostream>
#include<vector>
#include<chrono>
#include<cuda_runtime.h>

__host__ __device__ bool prime(int num) {
	if (num == 0)
		return false;
	for (int i = 2; i <= sqrtf(num); i++) {
		if (num % i == 0) {
			return false;
		}
	}
	return true;
}

bool primeSimple(int num) {
	for (int i = 2; i <= sqrtf(num); i++) {
		if (num % i == 0) {
			return false;
		}
	}
	return true;
}

std::vector<int> decomposition(int number, int count) {
	std::vector<int> summands;
	if (number < count) {
		return summands;
	}

	if (count == 2) {
		int temp = number - count;
		if (primeSimple(number) && primeSimple(temp)) {
			summands.push_back(count);
			summands.push_back(temp);
		}
		return summands;
	}

	if (count >= 3) {
		int remainingSum = number;
		for (int i = 2; i <= remainingSum; i++) {
			if (primeSimple(i)) {
				summands.push_back(i);
				remainingSum -= i;
				count--;
				if (count == 1) {
					summands.push_back(remainingSum);
					return summands;
				}
			}
		}
	}

	throw std::runtime_error("Decomposition not possible for the given number and count.");

	return summands;
}


__global__ void decompositionParallel(int number, int count, int summands[]) {

	if (number < count) {
		return;
	}

	if (count == 2) {
		int temp = number - count;
		if (prime(number) && prime(temp)) {
			summands[0] = count;
			summands[1] = temp;
		}
		return;
	}
	
	if (count >= 3) {
		int remainingSum = number;
		for (int i = 2, j = 0; i <= remainingSum; i++) {
			if (prime(i)) {
				summands[j] = i;
				remainingSum -= i;
				count--;
				if (count == 1) {
					summands[j] = remainingSum;
					return;
				}
				j++;
			}
		}
	}

	//throw std::runtime_error("Decomposition not possible for the given number and count.");return
	return;
}

int main() {
	int N = 0;
	int k = 0;
	int threads = 1;

	std::cout << "Enter N: ";
	std::cin >> N;

	std::cout << "Enter k: ";
	std::cin >> k;

	std::cout << "Enter the numbers of threads: ";
	std::cin >> threads;

	int simpleNum = N + 1;
	while (!prime(simpleNum)) {
		simpleNum++;
	}

	std::cout << "Min prime number: " << simpleNum << std::endl;

	std::vector<int> primers;
	//int *arr = new int[k];

	//Simple
	auto start = std::chrono::high_resolution_clock::now();
	try
	{
		primers = decomposition(simpleNum, k);
	}
	catch (const std::runtime_error& e) {}
	auto end = std::chrono::high_resolution_clock::now();
	std::chrono::duration<float> duration = end - start;


	//Parallel
	int *dev_summands;
	cudaMalloc((void**)&dev_summands, k * sizeof(int));


	int blockSize = 256;
	int numBlocks = (k + blockSize - 1) / blockSize;
	auto startP = std::chrono::high_resolution_clock::now();

	decompositionParallel << <blockSize, numBlocks >> > (simpleNum, k, dev_summands);
	cudaDeviceSynchronize();
	auto endP = std::chrono::high_resolution_clock::now();

	cudaMemcpy(&primers[0], dev_summands, k * sizeof(int), cudaMemcpyDeviceToHost);

	std::chrono::duration<float> durationP = endP - startP;

	cudaFree(dev_summands);


	std::cout << std::endl;

	if (primers.empty()) {
		std::cout << "Decomposition is not possible." << std::endl;
	}
	else {
		std::cout << "Summands: ";
		int size = 0;
		k <= 5 ? size = k : size = 5;
		for (int i = 0; i < size; i++) {
			std::cout << primers.at(i) << " ";
		}
		std::cout << std::endl << std::endl;


		/*std::cout << "Arr Result: ";
		for (int i = 0; i < size; i++) {
			std::cout << arr[i] << " ";
		}*/
	}
	std::cout << "Time: " << duration.count() << std::endl;
	std::cout << "Parallel time: " << durationP.count() << std::endl;

	return 0;
}
